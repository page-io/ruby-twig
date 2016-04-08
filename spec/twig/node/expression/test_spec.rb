describe Twig::Node::Expression::Test do

  it 'Constructor' do
    expr = Twig::Node::Expression::Constant.new('foo', 1)
    name = Twig::Node::Expression::Constant.new('nil', 1)
    args = Twig::Node.new

    node = Twig::Node::Expression::Test.new(expr, name, args, 1)

    expect(node.get_node('node')).to eq(expr)
    expect(node.get_node('arguments')).to eq(args)
    expect(node.get_attribute('name')).to eq(name)
  end

  describe ' ' do
    let(:environment) {
      Twig::Environment.new(nil)
    }
    let(:compiler) {
      Twig::Compiler.new(environment)
    }
    let(:string) {
      # arbitrary named arguments
      Twig::Node::Expression::Constant.new('abc', 1)
    }

    def create_test(node, name, arguments = {})
      Twig::Node::Expression::Test.new(node, name, Twig::Node.new(arguments), 1)
    end

    it ' ' do
      environment.add_test(Twig::SimpleTest.new('barbar', 'twig_tests_test_barbar', { is_variadic: true, need_context: true }))

      expr = Twig::Node::Expression::Constant.new('foo', 1)
      node = Twig::Node::Expression::Test::Null.new(expr, 'nil', Twig::Node.new, 1)

      expect(compiler.compile(node).get_source).to eq('("foo").nil?')
    end

    it ' ' do
      environment.add_test(Twig::SimpleTest.new('anonymous', ->(){}))
      node = create_test(Twig::Node::Expression::Constant.new('foo', 1), 'anonymous', {
        0 => Twig::Node::Expression::Constant.new('foo', 1)
      })

      expect(compiler.compile(node).get_source).to eq('call_user_func(@env.get_test(\'anonymous\').callable, ("foo", "foo"))')
    end

    def twig_tests_test_barbar(string, arg1 = nil, arg2 = nil, *args)
    end

    it ' ' do
      environment.add_test(Twig::SimpleTest.new('barbar', [self,'twig_tests_test_barbar'], { is_variadic: true, need_context: true }))
      node = create_test(string, 'barbar')

      expect(compiler.compile(node).get_source).to eq("call_user_func(@env.get_test('barbar').callable, (\"abc\"))")
    end

    it ' ' do
      environment.add_test(Twig::SimpleTest.new('barbar', [self,'twig_tests_test_barbar'], { is_variadic: true, need_context: true }))
      node = create_test(string, 'barbar', {
        'foo' => Twig::Node::Expression::Constant.new('bar', 1)
      })

      expect{compiler.compile(node).get_source}.to raise_error(Twig::Error::Syntax, "Value for argument \"args\" is required for test \"barbar\".")
    end

    it ' ' do
      environment.add_test(Twig::SimpleTest.new('barbar', [self,'twig_tests_test_barbar'], { is_variadic: true, need_context: true }))
      node = create_test(string, 'barbar', {
        'arg2' => Twig::Node::Expression::Constant.new('bar', 1)
      })

      expect{compiler.compile(node).get_source}.to raise_error(Twig::Error::Syntax, "Argument \"arg2\" could not be assigned for test \"barbar(arg1, arg2)\" because it is mapped to a function which cannot determine default value for optional argument \"arg1\".")
    end

    it ' ' do
      environment.add_test(Twig::SimpleTest.new('barbar', [self,'twig_tests_test_barbar'], { is_variadic: true, need_context: true }))

      node = create_test(string, 'barbar', {
        0 => Twig::Node::Expression::Constant.new('1', 1),
        1 => Twig::Node::Expression::Constant.new('2', 1),
        2 => Twig::Node::Expression::Constant.new('3', 1),
        'foo' => Twig::Node::Expression::Constant.new('bar', 1),
      })

      expect(compiler.compile(node).get_source).to eq('call_user_func(@env.get_test(\'barbar\').callable, ("abc", "1", "2", "3", {"foo" => "bar"}))')
    end
  end
end
