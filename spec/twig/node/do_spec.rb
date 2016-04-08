describe Twig::Node::Do do
  it 'Constructor' do
    expr = Twig::Node::Expression::Constant.new('foo', 1)

    node = Twig::Node::Do.new(expr, 1)

    expect(node.get_node(:expr)).to eq(expr)
  end

  describe ' ' do

    let(:environment) {
      Twig::Environment.new(nil)
    }
    let(:compiler) {
      Twig::Compiler.new(environment)
    }

    it 'getTests' do
      expr = Twig::Node::Expression::Constant.new('foo', 1)

      node = Twig::Node::Do.new(expr, 1)

      expect(compiler.compile(node).get_source).to eq("# line 1\n\"foo\"\n")
    end
  end
end
