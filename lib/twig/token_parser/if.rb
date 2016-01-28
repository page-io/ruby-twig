module Twig
  class TokenParser::If < Twig::TokenParser

    # {% if <expression> %}
    # ...
    # {% elseif <expression>%}
    # ...
    # {% else %}
    # ...
    # {% endif %}
    def parse(token)
      lineno = token.lineno
      expr = @parser.expression_parser.parse_expression
      stream = @parser.stream
      stream.expect(:block_end_type)
      body = @parser.subparse([self, :decide_if_fork])
      tests = [expr, body]
      _else = nil
      _end = false
      until _end
        case stream.next.value
        when 'else'.freeze
          stream.expect(:block_end_type)
          _else = @parser.subparse([self, :decide_if_end])
        when 'elseif'.freeze
          expr = @parser.expression_parser.parse_expression
          stream.expect(:block_end_type)
          body = @parser.subparse([self, :decide_if_fork])
          tests << expr << body
        when 'endif'.freeze
          _end = true
        else
          raise Twig::Error::Syntax.new("Unexpected end of template. Twig was looking for the following tags \"else\", \"elseif\", or \"endif\" to close the \"if\" block started at line #{lineno}).", stream.current_token.lineno, stream.filename)
        end
      end
      stream.expect(:block_end_type)
      Twig::Node::If.new(Twig::Node.new(tests), _else, lineno, tag)
    end

    def decide_if_fork(token)
      token.check(['elseif'.freeze, 'else'.freeze, 'endif'.freeze])
    end

    def decide_if_end(token)
      token.check(['endif'.freeze])
    end

    def tag
      'if'.freeze
    end

  end
end
