module Twig
  class Node::Expression::Function < Node::Expression::Call

    def initialize(name, arguments, line)
      super({'arguments' => arguments}, {'name' => name}, line)
    end

    def compile(compiler)
      name = get_attribute('name')
      function = compiler.environment.get_function(name)

      # set_attribute('name', name)
      set_attribute(:type, :function)
      set_attribute(:thing, function)
      set_attribute(:needs_environment, function.needs_environment?)
      set_attribute(:needs_context, function.needs_context?)
      set_attribute('arguments', function.arguments)

      if function.is_a?(Twig::SimpleFunction) || function.is_a?(Twig::FunctionCallable)
        set_attribute(:callable, function.get_callable)
      end
      if function.is_a?(Twig::SimpleFunction)
        set_attribute(:is_variadic, function.is_variadic)
      end

      compile_callable(compiler)
    end

  end
end
