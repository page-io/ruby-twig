module Twig
  class Node::Expression::Test < Node::Expression::Call

    def initialize(node, name, arguments, lineno)
      super({'node' => node, 'arguments' => arguments}, {'name' => name}, lineno)
    end

    def compile(compiler)
      name = get_attribute('name')
      _test = compiler.environment.get_test(name)

      set_attribute('name', name)
      set_attribute(:type, 'test')
      set_attribute(:thing, _test)

      if _test.is_a?(Twig::SimpleTest)
        set_attribute(:callable, _test.callable)
        set_attribute(:is_variadic, _test.is_variadic)
      end

      compile_callable(compiler)
    end

  end
end
