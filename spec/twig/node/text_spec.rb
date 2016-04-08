describe Twig::Node::Text do
  it 'Constructor' do
    node = Twig::Node::Text.new('foo', 1)
    expect(node.get_attribute('data')).to eq('foo')
  end

  let(:environment) {
    Twig::Environment.new(nil)
  }
  let(:compiler) {
    Twig::Compiler.new(environment)
  }

  it ' ' do
    node = Twig::Node::Text.new('foo', 1)
    expect(compiler.compile(node).get_source).to eq("# line 1\n_twigout << \"foo\"\n")
  end
end
