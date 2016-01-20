module Twig
  class NodeVisitor::Escaper < Twig::NodeVisitor

    # protected $traverser;
    def initilize()
      @safe_analysis = Twig::NodeVisitor::SafeAnalysis.new
      @safe_vars = []
      @status_stack = []
      @blocks = {}
      @default_strategy = false
    end

    def enter_node(node, env)
      if node.is_a?(Twig::Node::Module)
        if (env.has_extension('escaper') && default_strategy = env.get_extension('escaper').get_default_strategy(node.get_attribute('filename')))
          @default_strategy = default_strategy
        end
        @safe_vars = []
      elsif node.is_a?(Twig::Node::AutoEscape)
        @status_stack << node.get_attribute('value')
      elsif node.is_a?(Twig::Node::Block)
        @status_stack << (@blocks.key?(node.get_attribute('name')) ? @blocks[node.get_attribute('name')] : need_escaping(env))
      elsif node.is_a?(Twig::Node::Import)
        @safe_vars << node.get_node('var').get_attribute('name')
      end
      node
    end

    def leave_node(node, env)
      if node.is_a?(Twig::Node::Module)
        @default_strategy = false
        @safe_vars = []
      elsif node.is_a?(Twig::Node::Expression_Filter)
        return pre_escape_filter_node(node, env)
      elsif node.is_a?(Twig::Node::Print)
        return escape_print_node(node, env, need_escaping(env))
      end
      if node.is_a?(Twig::Node::AutoEscape) || node.is_a?(Twig::Node::Block)
        @status_stack.pop
      elsif node.is_a?(Twig::Node::BlockReference)
        @blocks[node.get_attribute('name')] = need_escaping(env)
      end
      node
    end

    def escape_print_node(node, env, type)
      if false == type
        return node
      end
      expression = node.get_node('expr')
      if is_safe_for(type, expression, env)
        return node
      end
      klass = node.class
      klass.new(get_escaper_filter(type, expression),node.lineno)
    end

    def pre_escape_filter_node(filter, env)
      name = filter.get_node('filter').get_attribute('value')
      type = env.get_filter(name).get_pre_escape()
      if (nil == type)
        return filter
      end
      node = filter.get_node('node')
      if is_safe_for(type, node, env)
        return filter
      end
      filter.set_node('node', get_escaper_filter(type, node))
      filter
    end

    def is_safe_for(type, expression, env)
      safe = @safe_analysis.get_safe(expression)
      if nil == safe
        if nil == @traverser
          @traverser = Twig::NodeTraverser.new(env, [@safe_analysis])
        end
        @safe_analysis.set_safe_vars(@safe_vars)
        @traverser.traverse(expression)
        safe = @safe_analysis.get_safe(expression)
      end
      safe.include?(type) || safe.include?('all')
    end

    def need_escaping(env)
      if @status_stack.count
        return @status_stack[@status_stack.count - 1]
      end
      @default_strategy ? @default_strategy : false
    end

    def get_escaper_filter(type, node)
      line = node.lineno
      name = Twig::Node::Expression::Constant.new('escape', line)
      args = Twig::Node.new({
        0 => Twig::Node::Expression::Constant.new(type, line),
        1 => Twig::Node::Expression::Constant.new(nil, line),
        2 => Twig::Node::Expression::Constant.new(true, line)
      })
      Twig::Node::Expression::Filter.new(node, name, args, line)
    end

    def get_priority
      0
    end

  end
end
