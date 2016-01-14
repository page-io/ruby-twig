module Twig
  class TokenParser::Macro < Twig::TokenParser

    def parse(token)
      lineno = token.lineno
      stream = @parser.get_stream
      name = stream.expect(:name_type).value
      arguments = @parser.get_expression_parser.parse_arguments(true, true)
      stream.expect(:block_end_type)
      @parser.push_local_scope
      body = @parser.subparse([self, :decide_block_end], true)
      if (token = stream.next_if(:name_type))
        value = token.value
        if (value != name)
          raise Twig::Error::Syntax.new("Expected endmacro for macro \"#{name}\" (but \"#{value}\" given).", stream.current_token.lineno, stream.get_filename)
        end
      end
      @parser.pop_local_scope
      stream.expect(:block_end_type)
      @parser.set_macro(name, Twig::Node::Macro.new(name, Twig::Node::Body.new([body]), arguments, lineno, tag))
    end

    def decide_block_end(token)
      token.check('endmacro'.freeze)
    end

    def tag
      'macro'.freeze
    end
  end
end
