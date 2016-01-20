module Twig
  class TokenParser::Extends < Twig::TokenParser

    def parse(token)
      unless @parser.is_main_scope
        raise Twig::Error::Syntax.new('Cannot extend from a block.', token.lineno, @parser.filename)
      end
      if @parser.parent
        raise Twig::Error::Syntax.new('Multiple extends tags are forbidden.', token.lineno, @parser.filename)
      end
      @parser.parent = @parser.get_expression_parser.parse_expression
      @parser.stream.expect(:block_end_type)
      nil
    end

    def tag
      'extends'.freeze
    end
  end
end
