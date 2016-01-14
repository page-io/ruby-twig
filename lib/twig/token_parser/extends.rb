module Twig
  class TokenParser::Extends < Twig::TokenParser

    def parse(token)
      unless @parser.is_main_scope
        raise Twig::Error::Syntax.new('Cannot extend from a block.', token.lineno, @parser.get_filename)
      end
      if @parser.get_parent
        raise Twig::Error::Syntax.new('Multiple extends tags are forbidden.', token.lineno, @parser.get_filename)
      end
      @parser.set_parent(@parser.get_expression_parser.parse_expression)
      @parser.get_stream.expect(:block_end_type)
      nil
    end

    def tag
      'extends'.freeze
    end
  end
end
