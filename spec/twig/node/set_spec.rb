describe Twig::Node::Set do

  let(:environment) {
    Twig::Environment.new(nil)
  }
  let(:compiler) {
    Twig::Compiler.new(environment)
  }

  it 'constructor' do
    names = Twig::Node.new([Twig::Node::Expression::AssignName.new('foo', 1)], {}, 1)
    values = Twig::Node.new([Twig::Node::Expression::Constant.new('foo', 1)], {}, 1)
    node = Twig::Node::Set.new(false, names, values, 1)

    expect(names).to eq(node.get_node('names'))
    expect(values).to eq(node.get_node('values'))
    expect(node.get_attribute(:capture)).to eq false
  end

  it 'simple assign' do
    names = Twig::Node.new([Twig::Node::Expression::AssignName.new('foo', 1)], {}, 1)
    values = Twig::Node.new([Twig::Node::Expression::Constant.new('foo', 1)], {}, 1)
    node = Twig::Node::Set.new(false, names, values, 1)

    expect(compiler.compile(node).get_source).to eq(<<-EOF
# line 1
_context["foo"] = "foo"
EOF
    )
  end

  it ' ' do
    names = Twig::Node.new([Twig::Node::Expression::AssignName.new('foo', 1)], nil, 1)
    values = Twig::Node.new([
      Twig::Node::Print.new(Twig::Node::Expression::Constant.new('foo', 1), 1)
    ], {}, 1)
    node = Twig::Node::Set.new(true, names, values, 1)
    expect(compiler.compile(node).get_source).to eq(<<-EOF
# line 1
_context["foo"] = begin
  _twigout = []
  _twigout << "foo".to_s
  _twigout.join
end

EOF
    )
  end

  it ' ' do
    names = Twig::Node.new([Twig::Node::Expression::AssignName.new('foo', 1)], nil, 1)
    values = Twig::Node::Text.new('foo', 1)
    node = Twig::Node::Set.new(true, names, values, 1)
    expect(compiler.compile(node).get_source).to eq(<<-EOF
# line 1
_context["foo"] = "foo"
EOF
    )
  end

  it ' ' do
    names = Twig::Node.new([
      Twig::Node::Expression::AssignName.new('foo', 1),
      Twig::Node::Expression::AssignName.new('bar', 1)
    ], nil, 1)
    values = Twig::Node.new([
      Twig::Node::Expression::Constant.new('foo', 1),
      Twig::Node::Expression::Name.new('bar', 1)
    ], nil, 1)
    node = Twig::Node::Set.new(false, names, values, 1)
    expect(compiler.compile(node).get_source).to eq(<<-EOF
# line 1
_context["foo"],_context["bar"] = ["foo",_context["bar"]]
EOF
    )
  end

end
