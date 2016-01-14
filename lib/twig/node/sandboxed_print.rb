module Twig
  class Node::SandboxedPrint < Twig::Node

    def initialize(expr, lineno, tag = nil)
      super({expr: expr}, nil, lineno, tag)
    end

    def compile(compiler)
      compiler
        .add_debug_info(self)
        .write('_twigout << @env.get_extension(\'sandbox\').ensure_to_string_allowed(')
        .subcompile(get_node(:expr))
        .raw(")\n")
    end

    # Removes node filters.
    #
    # This is mostly needed when another visitor adds filters (like the escaper one).
    #
    # @param node [Twig::Node] A node
    #
    # @return [Twig::Node]
    def remove_node_filter(node)
      if node.is_a?(Twig::Node::Expression::Filter)
        remove_node_filter(node.get_node('node'))
      end
      node
    end

  end
end
