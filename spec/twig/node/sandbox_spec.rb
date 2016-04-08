describe Twig::Node::Sandbox do
  it 'Constructor' do
    body = Twig::Node::Text.new('foo', 1)
    node = Twig::Node::Sandbox.new(body, 1)

    expect(node.get_node(:body)).to eq(body)
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
      node = Twig::Node::Sandbox.new(body, 1)

      expect(compiler.compile(node).get_source).to eq(<<-EOF
# line 1
_sandbox = @env.get_extension('sandbox')
unless _already_sandboxed = _sandbox.is_sandboxed
  _sandbox.enable_sandbox
end
_twigout << "foo"
unless _already_sandboxed
  _sandbox.disable_sandbox
end
EOF
      )
    end
  end
end
