describe Twig::Node::BlockReference do
  it 'Constructor' do
    node = Twig::Node::BlockReference.new('foo', 1)

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
      node = Twig::Node::BlockReference.new('foo', 1)

      expect(compiler.compile(node).get_source).to eq(<<-EOF
# line 1
_twigout << display_block('foo', _context, blocks)
EOF
      )
    end
  end
end
