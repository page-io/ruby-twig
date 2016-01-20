module Twig
  class TokenParser::Block < Twig::TokenParser

    def parse(token)
      lineno = token.lineno
      stream = @parser.stream
      name = stream.expect(:name_type).value
      if @parser.has_block(name)
       raise Twig::Error::Syntax.new("The block '#{name}' has already been defined line #{@parser.get_block(name).lineno}.", stream.current_token.lineno, stream.filename)
      end
      @parser.set_block(name, block = Twig::Node::Block.new(name, Twig::Node.new, lineno))
      @parser.push_local_scope
      @parser.push_block_stack(name)
      if stream.next_if(:block_end_type)
        body = @parser.subparse([self, :decide_block_end], true)
        if token = stream.next_if(:name_type)
          value = token.value
          if value != name
            raise Twig::Error::Syntax.new("Expected endblock for block \"#{name}\" (but \"#{value}\" given).", stream.current_token.lineno, stream.filename)
          end
        end
      else
        body = Twig::Node.new([
          Twig::Node::Print.new(@parser.get_expression_parser.parse_expression, lineno)
        ])
      end
      stream.expect(:block_end_type)
      block.set_node(:body, body)
      @parser.pop_block_stack
      @parser.pop_local_scope
      Twig::Node::BlockReference.new(name, lineno, tag)
    end

    def decide_block_end(token)
      token.check('endblock'.freeze)
    end

    def tag
      'block'.freeze
    end
  end
end
