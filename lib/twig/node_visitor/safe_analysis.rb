module Twig
  class NodeVisitor::SafeAnalysis < Twig::NodeVisitor

    # protected $data = [];
    # protected safeVars = [];

    def setSafeVars(safe_vars)
      @safe_vars = safe_vars
    end

    def get_safe(node)
      hash = spl_object_hash(node)
      if @data.key?(hash)
        return
      end
      @data[hash].each do |bucket|
        if bucket['key'] != node
          next
        end
        if bucket['value'].include?('html_attr')
          bucket['value'][] = 'html'
        end
        return bucket['value']
      end
    end

    def set_safe(node, safe)
      hash = spl_object_hash(node)
      if @data.key?(hash)
        @data[hash].each do |bucket|
          if (bucket['key'] === node)
            bucket['value'] = safe
            return
          end
        end
      end
      @data[hash] << {
        'key' => node,
        'value' => safe,
      }
    end

    def leave_node(node, env)
      if node.is_a?(Twig::Node::Expression::Constant)
        # constants are marked safe for all
        set_safe(node, ['all'])
      elsif node.is_a?(Twig::Node::Expression::BlockReference)
        # blocks are safe by definition
        set_safe(node, ['all'])
      elsif node.is_a?(Twig::Node::Expression::Parent)
        # parent block is safe by definition
        set_safe(node, ['all'])
      elsif node.is_a?(Twig::Node::Expression::Conditional)
        # intersect safeness of both operands
        safe = intersect_safe(get_safe(node.get_node('expr2')), get_safe(node.get_node('expr3')))
        set_safe(node, safe);
      elsif node.is_a?(Twig::Node::Expression::Filter)
        # filter expression is safe when the filter is safe
        name = node.get_node('filter').get_attribute('value')
        args = node.get_node('arguments')
        if (false != filter = env.get_filter(name))
          safe = filter.get_safe(args)
          if (nil == safe)
              safe = this.intersect_safe(get_safe(node.get_node('node')), filter.get_preserves_safety())
          end
          set_safe(node, safe)
        else
          set_safe(node, [])
        end
      elsif node.is_a?(Twig::Node::Expression::Function)
        # function expression is safe when the function is safe
        name = node.get_attribute('name')
        args = node.get_node('arguments')
        function = env.get_function(name)
        if (false != function)
          set_safe(node, function.get_safe(args))
        else
          set_safe(node, [])
        end
      elsif node.is_a?(Twig::Node::Expression::MethodCall)
        if node.get_attribute('safe')
          set_safe(node, ['all'])
        else
          set_safe(node, [])
        end
      elsif node.is_a?(Twig::Node::Expression::GetAttr) && node.get_node('node').is_a?(Twig::Node::Expression::Name)
        name = node.get_node('node').get_attribute('name')
        # attributes on template instances are safe
        if '_self' == name || @safe_vars.include?(name)
          set_safe(node, ['all'])
        else
          set_safe(node, [])
        end
      else
        set_safe(node, [])
      end
      node
    end

    def intersect_safe(a = nil, b = nil)
      if (nil == a || nil == b)
        return []
      end
      if a.include?('all')
        return b
      end
      if b.include?('all')
        return a
      end
      array_intersect(a, b)
    end

    def get_priority
      0
    end

  end
end
