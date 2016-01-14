module Twig
  class NodeTraverser

    # Constructor.
    #
    # @param Twig_Environment            $env      A Twig_Environment instance
    # @param Twig_NodeVisitorInterface[] visitors An array of Twig_NodeVisitorInterface instances
    def initialize(env,  visitors = [])
      @env = env
      @visitors = visitors
      visitors.each do |visitor|
        add_visitor(visitor)
      end
    end

    # Adds a visitor.
    #
    # @param Twig_NodeVisitorInterface visitor A Twig_NodeVisitorInterface instance
    def addVisitor(visitor)
      if !(@visitors.key?(visitor.get_priority))
        @visitors[visitor.get_priority] = []
      end
      @visitors[visitor.get_priority] << visitor
    end

    # Traverses a node and calls the registered visitors.
    #
    # @param Twig_NodeInterface node A Twig_NodeInterface instance
    #
    # @return Twig_NodeInterface
    def traverse(node)
      #ksort(@visitors)
      @visitors.each do |visitors|
        visitors.each do |visitor|
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
