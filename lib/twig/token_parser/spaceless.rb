module Twig
  class TokenParser::Spaceless < Twig::TokenParser

    def parse(token)
      @parser.stream.expect(:block_end_type)
      body = @parser.subparse([self, :decide_spaceless_end], true)
      @parser.stream.expect(:block_end_type)
      Twig::Node::Spaceless(body, token.lineno, tag)
    end

    def decide_block_end(token)
      token.check('endspaceless'.freeze)
    end

    def tag
      'spaceless'.freeze
    end
  end
end
