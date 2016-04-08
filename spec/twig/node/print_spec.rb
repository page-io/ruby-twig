describe Twig::Node::Print do
  it 'Constructor' do
    expr = Twig::Node::Expression::Constant.new('foo', 1)

    node = Twig::Node::Print.new(expr, 1)

    expect(node.get_node(:expr)).to eq(expr)
  end

  describe ' ' do
    let(:environment) {
      Twig::Environment.new(nil)
    }
    let(:compiler) {
      Twig::Compiler.new(environment)
    }

    it ' ' do
      node = Twig::Node::Print.new(Twig::Node::Expression::Constant.new('foo', 1), 1)
      expect(compiler.compile(node).get_source).to eq("# line 1\n_twigout << \"foo\".to_s\n")
    end

  end
end
