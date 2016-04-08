describe Twig::Node::Block do
  it 'Constructor' do
    body = Twig::Node::Text.new('foo', 1)

    node = Twig::Node::Block.new('foo', body, 1)

    expect(node.get_node(:body)).to eq(body)
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
      body = Twig::Node::Text.new('foo', 1)

      node = Twig::Node::Block.new('foo', body, 1)

      expect(compiler.compile(node).get_source).to eq(<<-EOF
# line 1
def block_foo(_context, blocks = [])
  _twigout = []
  _twigout << "foo"
  _twigout.join
end

EOF
      )
    end
  end
end
