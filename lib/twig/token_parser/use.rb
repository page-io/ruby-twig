module Twig
  class TokenParser::Use < Twig::TokenParser
    def parse(token)
      template = @parser.get_expression_parser.parse_expression
      stream = @parser.get_stream
      if !template.is_a?(Twig::Node::Expression::Constant)
        raise Twig::Error::Syntax.new('The template references in a "use" statement must be a string.', stream.current_token.lineno, stream.filename)
      end
      targets = []
      if stream.next_if('with'.freeze)
        while true
          name = stream.expect(:name_type).value
          name_alias = name
          if stream.next_if('as'.freeze)
            name_alias = stream.expect(:name_type).value
          end
          targets[name] = Twig::Node::Expression::Constant.new(name_alias, -1)
          unless stream.next_if(:punctuation_type, ','.freeze)
            break
          end
        end
      end
      stream.expect(:block_end_type)
      @parser.add_trait(Twig::Node.new({ 'template' => template, 'targets' => Twig::Node.new(targets) }))
    end

    def tag
      'use'.freeze
    end
  end
end
