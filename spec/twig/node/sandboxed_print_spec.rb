describe Twig::Node::SandboxedPrint do
  it 'Constructor' do
    node = Twig::Node::SandboxedPrint.new(expr = Twig::Node::Expression::Constant.new('foo', 1), 1)
    expect(node.get_node(:expr)).to eq(expr)
  end

  let(:environment) {
    Twig::Environment.new(nil)
  }
  let(:compiler) {
    Twig::Compiler.new(environment)
  }

  it ' '  do
    node = Twig::Node::SandboxedPrint.new(Twig::Node::Expression::Constant.new('foo', 1), 1)

    expect(compiler.compile(node).get_source).to eq(<<-EOF
# line 1
_twigout << @env.get_extension('sandbox').ensure_to_string_allowed("foo")
EOF
    )
  end
end
