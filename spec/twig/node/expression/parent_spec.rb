describe Twig::Node::Expression::Parent do

  it 'Constructor' do
    node = Twig::Node::Expression::Parent.new('foo', 1)

    expect(node.get_attribute('name')).to eq('foo')
  end

  describe ' ' do
    let(:environment) {
      Twig::Environment.new(nil)
    }
    let(:compiler) {
      Twig::Compiler.new(environment)
    }

    it ' ' do
      node = Twig::Node::Expression::Parent.new('foo', 1)
      expect(compiler.compile(node).get_source).to eq('render_parent_block("foo", _context, blocks)')
    end
  end
end
