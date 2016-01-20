module Twig
  class NodeVisitor::Sandbox < Twig::NodeVisitor

    # protected $inAModule = false;
    # protected $tags;
    # protected $filters;
    # protected $functions;

    def enter_node(node, env)
      if node.is_a?(Twig::Node::Module)
        @in_a_module = true
        @tags = {}
        @filters = {}
        @functions = {}
        return node
      elsif @in_a_module
        # look for tags
        if node.get_node_tag && !@tags.key?(node.get_node_tag)
          @tags[node.get_node_tag] = node
        end
        # look for filters
        if node.is_a?(Twig::Node::Expression_Filter) && !@filters.key?(node.get_node('filter').get_attribute('value'))
          @filters[node.get_node('filter').get_attribute('value')] = node
        end
        # look for functions
        if node.is_a?(Twig::Node::Expression::Function) && !@functions.key?(node.get_attribute('name'))
          @functions[node.get_attribute('name')] = node
        end
        # wrap print to check __toString() calls
        if node.is_a?(Twig::Node::Print)
          return Twig::Node::SandboxedPrint.new(node.get_node('expr'), node.lineno, node.get_node_tag)
        end
      end
      node
    end

    def leave_node(node, env)
      if node.is_a?(Twig::Node::Module)
        @in_module = false
        node.set_node('display_start', Twig::Node.new([
          Twig::Node::CheckSecurity.new(@filters, @tags, @functions),
          node.get_node('display_start')
        ]))
      end
      node
    end

    def get_priority
      0
    end

  end
end
