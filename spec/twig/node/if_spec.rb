describe Twig::Node::If do
  it 'Constructor' do
    t = Twig::Node.new([
        Twig::Node::Expression::Constant.new(true, 1),
        Twig::Node::Print.new(Twig::Node::Expression::Name.new('foo', 1), 1),
    ], nil, 1)

    _else = nil
    node = Twig::Node::If.new(t, _else, 1)

    expect(t).to eq(node.get_node(:tests))

    expect(node.get_node(:else)).to be_nil

    _else = Twig::Node::Print.new(Twig::Node::Expression::Name.new('bar', 1), 1)

    node = Twig::Node::If.new(t, _else, 1)

    expect(_else).to eq(node.get_node(:else))
  end

  let(:environment) {
    Twig::Environment.new(nil)
  }
  let(:compiler) {
    Twig::Compiler.new(environment)
  }

  it ' ' do
    t = Twig::Node.new([
        Twig::Node::Expression::Constant.new(true, 1),
        Twig::Node::Print.new(Twig::Node::Expression::Name.new('foo', 1), 1),
    ], nil, 1)

    _else = nil
    node = Twig::Node::If.new(t, _else, 1)


    expect(compiler.compile(node).get_source).to eq(<<-EOF
# line 1
if true
  _twigout << _context["foo"].to_s
end
EOF
    )
  end

  it ' ' do
    t = Twig::Node.new([
        Twig::Node::Expression::Constant.new(true, 1),
        Twig::Node::Print.new(Twig::Node::Expression::Name.new('foo', 1), 1),
        Twig::Node::Expression::Constant.new(false, 1),
        Twig::Node::Print.new(Twig::Node::Expression::Name.new('bar', 1), 1),
    ], nil, 1)
    _else = nil
    node = Twig::Node::If.new(t, _else, 1)

    expect(compiler.compile(node).get_source).to eq(<<-EOF
# line 1
if true
  _twigout << _context["foo"].to_s
elsif false
  _twigout << _context["bar"].to_s
end
EOF
    )
  end

  it ' ' do
    t = Twig::Node.new([
        Twig::Node::Expression::Constant.new(true, 1),
        Twig::Node::Print.new(Twig::Node::Expression::Name.new('foo', 1), 1),
    ], nil, 1)

    _else = Twig::Node::Print.new(Twig::Node::Expression::Name.new('bar', 1), 1)

    node = Twig::Node::If.new(t, _else, 1)

    expect(compiler.compile(node).get_source).to eq(<<-EOF
# line 1
if true
  _twigout << _context["foo"].to_s
else
  _twigout << _context["bar"].to_s
end
EOF
    )
  end
end
