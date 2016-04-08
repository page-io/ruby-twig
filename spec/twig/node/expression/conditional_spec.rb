describe Twig::Node::Expression::Conditional do

  it 'Constructor' do
    expr1 = Twig::Node::Expression::Constant.new(1, 1)

    expr2 = Twig::Node::Expression::Constant.new(2, 1)

    expr3 = Twig::Node::Expression::Constant.new(3, 1)

    node = Twig::Node::Expression::Conditional.new(expr1, expr2, expr3, 1)

    expect(node.get_node('expr1')).to eq(expr1)
    expect(node.get_node('expr2')).to eq(expr2)
    expect(node.get_node('expr3')).to eq(expr3)
  end

  describe ' ' do
    let(:environment) {
      Twig::Environment.new(nil)
    }
    let(:compiler) {
      Twig::Compiler.new(environment)
    }

    it ' ' do
      expr1 = Twig::Node::Expression::Constant.new(1, 1)

      expr2 = Twig::Node::Expression::Constant.new(2, 1)

      expr3 = Twig::Node::Expression::Constant.new(3, 1)

      node = Twig::Node::Expression::Conditional.new(expr1, expr2, expr3, 1)

      expect(compiler.compile(node).get_source).to eq('((1) ? (2) : (3))')
    end
  end
end
