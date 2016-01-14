module Twig
  class TokenParser::Import < Twig::TokenParser

    def parse(token)
      macro = @parser.get_expression_parser.parse_expression
      @parser.get_stream.expect('as'.freeze)
      var = Twig::Node::Expression::AssignName.new(@parser.get_stream.expect(:name_type).value, token.lineno)
      @parser.get_stream.expect(:block_end_type)
      @parser.add_imported_symbol('template', var.get_attribute('name'))

      Twig::Node::Import.new(macro, var, token.lineno, tag)
    end

    def tag
      'import'.freeze
    end
  end
end
