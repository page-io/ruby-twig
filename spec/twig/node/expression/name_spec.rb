describe Twig::Node::Expression::Name do

  it 'Constructor' do
    node = Twig::Node::Expression::Name.new('foo', 1)

    expect(node.get_attribute('name')).to eq('foo')
  end

  describe ' ' do
    it ' ' do
      environment = Twig::Environment.new(double('Twig::Loader'), { 'strict_variables' => true})
      compiler = Twig::Compiler.new(environment)
      node = Twig::Node::Expression::Name.new('foo', 1)

      expect(compiler.compile(node).get_source).to eq("# line 1\n_context[\"foo\"] || get_context(_context, \"foo\")")
    end

    it ' ' do
      environment = Twig::Environment.new(double('Twig::Loader'), { 'strict_variables' => false})
      compiler = Twig::Compiler.new(environment)
      node = Twig::Node::Expression::Name.new('foo', 1)

      expect(compiler.compile(node).get_source).to eq("# line 1\n_context[\"foo\"]")
    end

    it ' ' do
      environment = Twig::Environment.new(double('Twig::Loader'))
      compiler = Twig::Compiler.new(environment)
      context = Twig::Node::Expression::Name.new('_context', 1)

      expect(compiler.compile(context).get_source).to eq("# line 1\n_context")
    end

  end
end
