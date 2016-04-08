describe Twig::Node::Expression::Hash do

  it 'Constructor' do
    elements = [Twig::Node::Expression::Constant.new('foo', 1),
      foo = Twig::Node::Expression::Constant.new('bar', 1)
    ]

    node = Twig::Node::Expression::Hash.new(elements, 1)

    expect(node.nodes[1]).to eq(foo)
  end

  describe ' ' do
    let(:environment) {
      Twig::Environment.new(nil)
    }
    let(:compiler) {
      Twig::Compiler.new(environment)
    }

    it ' ' do
      elements = [
        Twig::Node::Expression::Constant.new('foo', 1),
        Twig::Node::Expression::Constant.new('bar', 1),

        Twig::Node::Expression::Constant.new('bar', 1),
        Twig::Node::Expression::Constant.new('foo', 1)
      ]

      node = Twig::Node::Expression::Hash.new(elements, 1)

      expect(compiler.compile(node).get_source).to eq('{"foo" => "bar", "bar" => "foo"}')
    end
  end
end
