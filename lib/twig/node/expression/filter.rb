module Twig
  class Node::Expression::Filter < Node::Expression::Call

    def initialize(node, filterName, arguments, lineno, tag = nil)
      super({
        'node' => node,
        'filter' => filterName,
        'arguments' => arguments
      }, nil, lineno, tag)
    end

    def compile(compiler)
      name = get_node('filter').get_attribute('value')
      filter = compiler.environment.get_filter(name)

      set_attribute('name', name)
      set_attribute(:type, :filter)
      set_attribute(:thing, filter)
      set_attribute(:needs_environment, filter.needs_environment?)
      set_attribute(:needs_context, filter.needs_context?)
      set_attribute('arguments', filter.arguments)
      if filter.is_a?(Twig::SimpleFilter) || filter.is_a?(Twig::FilterCallableInterface)
        set_attribute(:callable, filter.callable)
      end
      if filter.is_a?(Twig::SimpleFilter)
        set_attribute(:is_variadic, filter.is_variadic)
      end

      compile_callable(compiler)
    end

  end
end
