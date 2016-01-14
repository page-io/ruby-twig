module Twig
  class TokenParser::Sandbox < Twig::TokenParser

    def parse(token)
      @parser.get_stream.expect(:block_end_type);
      body = @parser.subparse([self, :decide_block_end], true)
      @parser.get_stream.expect(:block_end_type)
      # in a sandbox tag, only include tags are allowed
      unless body.is_a?(Twig::Node::Include)
        body.each do |node|
          if node.is_a?(Twig:Node::Text) && ctype_space(node.get_attribute('data'))
            continue
          end
          unless node.is_a?(Twig::Node::Include)
            raise Twig::Error::Syntax.new('Only "include" tags are allowed within a "sandbox" section.', node.lineno, @parser.filename)
          end
        end
      end
      Twig::Node::Sandbox.new(body, token.lineno, tag)
    end

    def decide_block_end(token)
      token.check('endsandbox'.freeze)
    end

    def tag
      'sandbox'.freeze
    end
  end
end
