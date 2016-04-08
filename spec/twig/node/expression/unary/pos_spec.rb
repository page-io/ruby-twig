describe Twig::Node::Expression::Unary::Pos do

  it 'Constructor' do
    expr = Twig::Node::Expression::Constant.new(1, 1)
    node = Twig::Node::Expression::Unary::Pos.new(expr, 1)

    expect(node.get_node('node')).to eq(expr)
  end

  describe ' ' do
    let(:environment) {
      Twig::Environment.new(nil)
    }
    let(:compiler) {
      Twig::Compiler.new(environment)
    }

    it ' ' do
      node = Twig::Node::Expression::Constant.new(1, 1)
      node = Twig::Node::Expression::Unary::Pos.new(node, 1)

      expect(compiler.compile(node).get_source).to eq(' +1')
    end
  end
end
