module Twig
  class TokenParser::Filter < Twig::TokenParser

    def parse(token)
      name = @parser.get_var_name
      ref = Twig::Node::Expression::BlockReference.new(Twig::Node::Expression::Constant.new(name, token.lineno), true, token.lineno, tag)
      filter = @parser.get_expression_parser.parse_filter_expression_raw(ref, tag)
      @parser.stream.expect(:block_end_type)
      body = @parser.subparse([self, :decide_block_end], true)
      @parser.stream.expect(:block_end_type)
      block = Twig::Node::Block.new(name, body, token.lineno)
      @parser.set_block(name, block)
      Twig::Node::Print.new(filter, token.lineno, tag)
    end

    def decide_block_end(token)
      token.check('endfilter'.freeze)
    end

    def tag
      'filter'.freeze
    end
  end
end
