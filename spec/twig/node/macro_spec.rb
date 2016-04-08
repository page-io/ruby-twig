describe Twig::Node::Macro do
  it 'Constructor' do

    body = Twig::Node::Text.new('foo', 1)
    arguments = Twig::Node.new([Twig::Node::Expression::Name.new('foo', 1)], nil, 1)
    node = Twig::Node::Macro.new('foo', body, arguments, 1)

    expect(node.get_node(:body)).to eq(body)
    expect(node.get_node('arguments')).to eq(arguments)
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

      arguments = Twig::Node.new({
        'foo' => Twig::Node::Expression::Constant.new(nil, 1),
        'bar' => Twig::Node::Expression::Constant.new('Foo', 1),
      }, nil, 1)

      node = Twig::Node::Macro.new('foo', body, arguments, 1)

      expect(compiler.compile(node).get_source).to eq(<<-EOF
# line 1
def getfoo(__foo__ = nil, __bar__ = "Foo", __varargs__)
  _context = @env.merge_globals({
    "foo" => __foo__,
    "bar" => __bar__,
    "varargs" => __varargs__
  })
  blocks = []
  begin
    _twigout << "foo"
  rescue => ex
    raise
  end
  (_twigout.length > 0 ? Twig::Markup.new(_twigout, @env.get_charset) : '')
end
EOF
      )
    end
  end
end
