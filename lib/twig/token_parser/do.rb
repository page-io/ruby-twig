module Twig
  class TokenParser::Do < Twig::TokenParser

    def parse(token)
      expr = @parser.get_expression_parser.parse_expression
      @parser.stream.expect(:block_end_type)
      Twig::Node::Do.new(expr, token.lineno, tag)
    end

    def tag
      'do'.freeze
    end
  end
end
