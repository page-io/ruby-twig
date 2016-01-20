module Twig
  class TokenParser::From < Twig::TokenParser

    def parse(token)
      macro = @parser.get_expression_parser.parse_expression
      stream = @parser.stream
      stream.expect('import'.freeze)
      targets = {}
      while true
        name = stream.expect(:name_type).value
        _alias = name
        if stream.next_if('as'.freeze)
          _alias = stream.expect(:name_type).value
        end
        targets[name] = _alias
        if !stream.next_if(:punctuation_type, ',')
          break
        end
      end
      stream.expect(:block_end_type)
      node = Twig::Node::Import.new(macro, Twig::Node::Expression::AssignName.new(@parser.get_var_name, token.lineno), token.lineno, tag)
      targets.each do |_name,_alias|
        if @parser.is_reserved_macro_name(_name)
          raise Twig::Error::Syntax.new("\"#{_name}\" cannot be an imported macro as it is a reserved keyword.", token.lineno, stream.filename)
        end
        @parser.add_imported_symbol('function', _alias, 'get'+_name, node.get_node('var'))
      end
      node
    end

    def tag
      'from'.freeze
    end
  end
end
