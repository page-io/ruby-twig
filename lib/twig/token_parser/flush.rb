module Twig
  class TokenParser::Flush < Twig::TokenParser

    def parse(token)
      @parser.get_stream.expect(:block_end_type)
      Twig::Node::Flush.new(token.lineno, tag)
    end

    def tag
      'flush'.freeze
    end
  end
end
