describe Twig::Node::Spaceless do
  it 'Constructor' do
    body = Twig::Node.new([Twig::Node::Text.new('<div>   <div>   foo   </div>   </div>', 1)])
    node = Twig::Node::Spaceless.new(body, 1)

    expect(node.get_node(:body)).to eq(body)
  end

  let(:environment) {
    Twig::Environment.new(nil)
  }
  let(:compiler) {
    Twig::Compiler.new(environment)
  }

  it ' ' do
    body = Twig::Node.new([Twig::Node::Text.new('<div>   <div>   foo   </div>   </div>', 1)])
    node = Twig::Node::Spaceless.new(body, 1)

    expect(compiler.compile(node).get_source).to eq(<<-EOF
# line 1
_twigout << begin
  _twigout = ''
  _twigout << "<div>   <div>   foo   </div>   </div>"
  _twigout.gsub(/> +</, '><')
end
EOF
    )

  end
end
