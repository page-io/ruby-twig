module Twig
  class TokenParser::AutoEscape < Twig::TokenParser

    def parse(token)
      lineno = token.lineno
      stream = @parser.get_stream
      if stream.check(:block_end_type)
        value = 'html'
      else
        expr = @parser.get_expression_parser.parse_expression
        unless expr.is_a?(Twig::Node::Expression::Constant)
          raise Twig::Error::Syntax.new('An escaping strategy must be a string or a bool.', stream.current_token.lineno, stream.filename)
        end
        value = expr.get_attribute('value')
        compat = true == value || false == value
        if value == true # if set to true use 'html'
          value = 'html'
        end
        if compat && stream.check(:name_type)
          # @trigger_error('Using the autoescape tag with "true" or "false" before the strategy name is deprecated.', E_USER_DEPRECATED)
          unless value
            raise Twig::Error::Syntax.new('Unexpected escaping strategy as you set autoescaping to false.', stream.current_token.lineno, stream.filename)
          end
          value = stream.next.value
        end
      end
      stream.expect(:block_end_type)
      body = @parser.subparse([self, :decide_block_end], true)
      stream.expect(:block_end_type)
      Twig::Node::AutoEscape.new(value, body, lineno, tag)
    end

    def decide_block_end(token)
      token.check('endautoescape'.freeze)
    end

    def tag
      'autoescape'.freeze
    end

  end
end
