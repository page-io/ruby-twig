describe Twig::Node::Expression::Constant do

  it 'Constructor' do
    node = Twig::Node::Expression::Constant.new('foo', 1)

    expect(node.get_attribute('value')).to eq('foo')
  end

  describe ' ' do
    let(:environment) {
      Twig::Environment.new(nil)
    }
    let(:compiler) {
      Twig::Compiler.new(environment)
    }

    it ' ' do
      node = Twig::Node::Expression::Constant.new('foo', 1)

      expect(compiler.compile(node).get_source).to eq('"foo"')
    end
  end
end
