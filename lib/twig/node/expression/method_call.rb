module Twig
  class Node::Expression::MethodCall < Node::Expression

    def initialize(node, method, arguments, lineno)
      super({
          'node' => node,
          'arguments' => arguments
        },
        {
          'method' => method,
          safe: false
        }, lineno
      )

      if node.is_a?(Twig::Node::Expression::Name)
        node.set_attribute(:always_defined, true)
      end
    end

    def compile(compiler)
      compiler
        .subcompile(get_node('node'))
        .raw('.')
        .raw(get_attribute('method'))
        .raw('(')
      first = true
      get_node('arguments').get_key_value_pairs.each do |pair|
        unless first
          compiler.raw(', ')
        end
        first = false

        compiler.subcompile(pair['value'])
      end
      compiler.raw(')')
    end

  end
end
