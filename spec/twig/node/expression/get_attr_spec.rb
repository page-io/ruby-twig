describe Twig::Node::Expression::GetAttr do

  it 'Constructor' do
    expr = Twig::Node::Expression::Name.new('foo', 1)

    _attr = Twig::Node::Expression::Constant.new('bar', 1)

    args = Twig::Node::Expression::Array.new([], 1)
    args.add_element(Twig::Node::Expression::Name.new('foo', 1))
    args.add_element(Twig::Node::Expression::Constant.new('bar', 1))

    node = Twig::Node::Expression::GetAttr.new(expr, _attr, args, :array_call, 1)

    expect(node.get_node('node')).to eq(expr)
    expect(node.get_node('attribute')).to eq(_attr)
    expect(node.get_node('arguments')).to eq(args)
    expect(node.get_attribute(:type)).to eq(:array_call)
  end

  describe ' ' do

    let(:environment) {
      Twig::Environment.new(nil)
    }
    let(:compiler) {
      Twig::Compiler.new(environment)
    }

    it ' ' do
      expr = Twig::Node::Expression::Name.new('foo', 1)
      _attr = Twig::Node::Expression::Constant.new('bar', 1)
      args = Twig::Node::Expression::Array.new([], 1)
      node = Twig::Node::Expression::GetAttr.new(expr, _attr, args, :any_call, 1)

      expect(compiler.compile(node).get_source).to eq("get_attribute(# line 1\n_context[\"foo\"], \"bar\", [])")
    end

    it ' ' do
      expr = Twig::Node::Expression::Name.new('foo', 1)
      _attr = Twig::Node::Expression::Constant.new('bar', 1)
      args = Twig::Node::Expression::Array.new([], 1)
      node = Twig::Node::Expression::GetAttr.new(expr, _attr, args, :array_call, 1)

      expect(compiler.compile(node).get_source).to eq("get_attribute(# line 1\n_context[\"foo\"], \"bar\", [], :array_call)")
    end

    it ' ' do
      expr = Twig::Node::Expression::Name.new('foo', 1)
      _attr = Twig::Node::Expression::Constant.new('bar', 1)
      args = Twig::Node::Expression::Array.new([], 1)
      args.add_element(Twig::Node::Expression::Name.new('foo', 1))
      args.add_element(Twig::Node::Expression::Constant.new('bar', 1))

      node = Twig::Node::Expression::GetAttr.new(expr, _attr, args, :method_call, 1)

      expect(compiler.compile(node).get_source).to eq("get_attribute(# line 1\n_context[\"foo\"], \"bar\", [_context[\"foo\"],\"bar\"], :method_call)")
    end
  end
end
