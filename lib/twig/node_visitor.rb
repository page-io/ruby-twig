module Twig
  class NodeVisitor
    def enter_node(node, env)
      node
    end

    def leave_node(node, env)
      node
    end

    def get_priority
      0
    end
  end
end
