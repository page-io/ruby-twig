module Twig
  class NodeTraverser

    # Constructor.
    #
    # @param Twig_Environment            $env      A Twig_Environment instance
    # @param Twig_NodeVisitorInterface[] visitors An array of Twig_NodeVisitorInterface instances
    def initialize(env,  visitors = [])
      @env = env
      @visitors = {}
      visitors.each do |visitor|
        add_visitor(visitor)
      end
    end

    # Adds a visitor.
    #
    # @param Twig::NodeVisitor visitor A Twig::NodeVisitor instance
    def add_visitor(visitor)
      unless @visitors.key?(visitor.get_priority)
        @visitors[visitor.get_priority] = []
      end
      @visitors[visitor.get_priority] << visitor
    end

    # Traverses a node and calls the registered visitors.
    #
    # @param node [Twig::Node] A Twig::Node instance
    #
    # @return Twig::Node
    def traverse(node)
      @visitors.keys.sort.each do |priority|
        @visitors[priority].each do |visitor|
          node = traverse_for_visitor(visitor, node)
        end
      end
      node
    end

    def traverse_for_visitor(visitor, node = nil)
      if node.nil?
        return
      end
      node = visitor.enter_node(node, @env)
      node.each do |k, n|
        if (n = traverse_for_visitor(visitor, n))
          node.set_node(k, n)
        else
          node.remove_node(k)
        end
      end
      visitor.leave_node(node, @env)
    end
  end
end
