describe Twig::Node::Include  do
  it 'Constructor' do
    expr = Twig::Node::Expression::Constant.new('foo.twig', 1)
    node = Twig::Node::Include.new(expr, nil, false, false, 1)

    expect(node.get_node(:variables)).to be_nil
    expect(node.get_node(:expr)).to eq(expr)
    expect(node.get_attribute(:only)).to eq(false)
  end

  it 'Constructor' do
    expr = Twig::Node::Expression::Constant.new('foo.twig', 1)
    vars = Twig::Node::Expression::Array.new([
      Twig::Node::Expression::Constant.new('foo', 1),
      Twig::Node::Expression::Constant.new(true, 1)
    ], 1)
    node = Twig::Node::Include.new(expr, vars, true, false, 1)

    expect(node.get_node(:variables)).to eq(vars)
    expect(node.get_attribute(:only)).to eq(true)
  end

  describe 'include' do
    let(:environment) {
      Twig::Environment.new(nil)
    }
    let(:compiler) {
      Twig::Compiler.new(environment)
    }

    it 'template as expression constant' do
      expr = Twig::Node::Expression::Constant.new('foo.twig', 1)
      node = Twig::Node::Include.new(expr, nil, false, false, 1)

      expect(compiler.compile(node).get_source).to eq(<<-EOF
# line 1
_twigout << load_template("foo.twig",nil,1).display(_context)
EOF
      )
    end

    it 'template as expression' do
      expr = Twig::Node::Expression::Conditional.new(
        Twig::Node::Expression::Constant.new(true, 1),
        Twig::Node::Expression::Constant.new('foo', 1),
        Twig::Node::Expression::Constant.new('foo', 1),
        0
      )

      node = Twig::Node::Include.new(expr, nil, false, false, 1)

      expect(compiler.compile(node).get_source).to eq(<<-EOF
# line 1
_twigout << load_template(((true) ? ("foo") : ("foo")),nil,1).display(_context)
EOF
      )
    end

    it 'passing variables' do
      expr = Twig::Node::Expression::Constant.new('foo.twig', 1)
      vars = Twig::Node::Expression::Hash.new([
        Twig::Node::Expression::Constant.new('foo', 1),
        Twig::Node::Expression::Constant.new(true, 1)
      ], 1)
      node = Twig::Node::Include.new(expr, vars, false, false, 1)

      expect(compiler.compile(node).get_source).to eq(<<-EOF
# line 1
_twigout << load_template("foo.twig",nil,1).display(_context.merge({"foo" => true}))
EOF
      )
    end

    it ' ' do
      expr = Twig::Node::Expression::Constant.new('foo.twig', 1)
      vars = Twig::Node::Expression::Hash.new([
        Twig::Node::Expression::Constant.new('foo', 1),
        Twig::Node::Expression::Constant.new(true, 1)
      ], 1)
      node = Twig::Node::Include.new(expr, vars, true, false, 1)

      expect(compiler.compile(node).get_source).to eq(<<-EOF
# line 1
_twigout << load_template("foo.twig",nil,1).display({"foo" => true})
EOF
      )
    end

    it 'template as expression constant no variables and option :only' do
      expr = Twig::Node::Expression::Constant.new('foo.twig', 1)
      node = Twig::Node::Include.new(expr, nil, true, false, 1)

      expect(compiler.compile(node).get_source).to eq(<<-EOF
# line 1
_twigout << load_template("foo.twig",nil,1).display({})
EOF
      )
    end

    it ' ' do
      expr = Twig::Node::Expression::Constant.new('foo.twig', 1)
      vars = Twig::Node::Expression::Hash.new([
        Twig::Node::Expression::Constant.new('foo', 1),
        Twig::Node::Expression::Constant.new(true, 1)
      ], 1)
      node = Twig::Node::Include.new(expr, vars, true, true, 1)

      expect(compiler.compile(node).get_source).to eq(<<-EOF
# line 1
begin
  _twigout << load_template("foo.twig",nil,1).display({"foo" => true})
rescue Twig::Error::Loader
  # ignore missing template
end

EOF
      )
    end
  end
end
