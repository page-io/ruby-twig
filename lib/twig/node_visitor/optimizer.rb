module Twig
  class NodeVisitor::Optimizer < Twig::NodeVisitor

    OPTIMIZE_ALL = -1
    OPTIMIZE_NONE = 0
    OPTIMIZE_FOR = 2
    OPTIMIZE_RAW_FILTER = 4
    OPTIMIZE_VAR_ACCESS = 8

    # protected $loops = array();
    # protected $loopsTargets = array();
    # protected $optimizers;
    # protected prepended_nodes = array();
    # protected $inABody = false;

    #
    #  Constructor.
    #
    #  @param int $optimizers The optimizer mode
    #
    def initialize(optimizers = -1)
      if !optimizers.is_a?(Integer) || optimizers > (OPTIMIZE_FOR | OPTIMIZE_RAW_FILTER | OPTIMIZE_VAR_ACCESS)
        raise InvalidArgument.new("Optimizer mode \"#{optimizers}\" is not valid.")
      end
      @optimizers = optimizers
    end

    def enter_node(node, env)
      if (OPTIMIZE_FOR == (OPTIMIZE_FOR & @optimizers))
        enter_optimize_for(node, env)
      end
      if OPTIMIZE_VAR_ACCESS == (OPTIMIZE_VAR_ACCESS & @optimizers) && !env.is_strict_variables && !env.has_extension('sandbox')
        if @in_a_body
          if !node.is_a?(Twig::Node::Expression)
            if (get_class(node) != 'Twig::Node')
              array_unshift(@prepended_nodes, array())
            end
          else
            node = optimize_variables(node, env)
          end
        elsif node.is_a?(Twig::Node::Body)
          @in_a_body = true
        end
      end
      node
    end

    def leave_node(node, env)
        expression = node.is_a?(Twig::Node::Expression)
        if (OPTIMIZE_FOR == (OPTIMIZE_FOR & @optimizers))
          leave_optimize_for(node, env)
        end
        if (OPTIMIZE_RAW_FILTER == (OPTIMIZE_RAW_FILTER & @optimizers))
          node = optimize_raw_filter(node, env)
        end
        node = optimize_print_node(node, env)
        if (OPTIMIZE_VAR_ACCESS == (OPTIMIZE_VAR_ACCESS & @optimizers) && !env.is_strict_variables && !env.has_extension('sandbox'))
          if node.is_a?(Twig::Node::Body)
            @in_a_body = false
          elsif (@in_a_body)
            if (!expression && get_class(node) != 'Twig::Node' && prepended_nodes = array_shift(@prepended_nodes))
              nodes = []
              prepended_nodes.uniq.each do |name|
                nodes << Twig::Node::SetTemp.new(name, node.lineno)
              end
              nodes << node
              node = Twig::Node.new(nodes)
            end
          end
        end
        node
    end

    def optimize_variables(node, env)
      if ('Twig::Node::Expression::Name' == node.class.name && node.is_simple)
        @prepended_nodes[0] << node.get_attribute('name')
        return Twig::Node::Expression::TempName.new(node.get_attribute('name'), node.lineno)
      end
      node
    end

    #
    #  Optimizes print nodes.
    #
    #  It replaces:
    #
    #    * "echo $this->render(Parent)Block()" with "$this->display(Parent)Block()"
    #
    #  @param Twig::NodeInterface node A Node
    #  @param Twig_Environment   env  The current Twig environment
    #
    #  @return Twig::NodeInterface
    #
    def optimize_print_node(node, env)
      if !node.is_a?(Twig::Node::Print)
        return node
      end
      if (
          node.get_node('expr').is_a?(Twig::Node::Expression::BlockReference) ||
          node.get_node('expr').is_a?(Twig::Node::Expression::Parent)
      )
          node.get_node('expr').set_attribute('output', true);
          return node.get_node('expr')
      end
      node
    end

    #
    #  Removes "raw" filters.
    #
    #  @param Twig::NodeInterface node A Node
    #  @param Twig_Environment   env  The current Twig environment
    #
    #  @return Twig::NodeInterface
    #
    def optimize_raw_filter(node, env)
      if node.is_a?(Twig::Node::Expression::Filter) && 'raw' == node.get_node('filter').get_attribute('value')
        return node.get_node('node')
      end
      node
    end

    #
    #  Optimizes "for" tag by removing the "loop" variable creation whenever possible.
    #
    #  @param Twig::NodeInterface node A Node
    #  @param Twig_Environment   env  The current Twig environment
    #
    def enter_optimize_for(node, env)
        if node.is_a?(Twig::Node::For)
          # disable the loop variable by default
          node.set_attribute('with_loop', false);
          array_unshift(@loops, node);
          array_unshift(@loopsTargets, node.get_node('value_target').get_attribute('name'))
          array_unshift(@loopsTargets, node.get_node('key_target').get_attribute('name'))

        elsif !@loops
          # we are outside a loop
          return

        # when do we need to add the loop variable back?
        # the loop variable is referenced for the current loop
        elsif node.is_a?(Twig::Node::Expression::Name) && 'loop' == node.get_attribute('name')
          node.set_attribute('always_defined', true);
          add_loop_to_current

        # optimize access to loop targets
        elsif node.is_a?(Twig::Node::Expression::Name) && @loopsTargets.include?(node.get_attribute('name'))
          node.set_attribute('always_defined', true)

        # block reference
        elsif node.is_a?(Twig::Node::BlockReference) || node.is_a?(Twig::Node::Expression::BlockReference)
          add_loop_to_current

        # include without the only attribute
        elsif node.is_a?(Twig::Node::Include) && !node.get_attribute('only')
          add_loop_to_all

        # include function without the with_context=false parameter
        elsif node.is_a?(Twig::Node::Expression::Function) &&
            'include' == node.get_attribute('name') &&
            (!node.get_node('arguments').has_node('with_context') ||
               false != node.get_node('arguments').get_node('with_context').get_attribute('value')
            )
          add_loop_to_all

        # the loop variable is referenced via an attribute
        elsif node.is_a?(Twig::Node::Expression::GetAttr) &&
            (!node.get_node('attribute').is_a?(Twig::Node::Expression::Constant) ||
              'parent' == node.get_node('attribute').get_attribute('value')
            ) &&
            (true == @loops[0].get_attribute('with_loop') ||
              (node.get_node('node').is_a?(Twig::Node::Expression::Name) &&
                'loop' == node.get_node('node').get_attribute('name')
              )
            )
          add_loop_to_all
        end
    end

    #
    #  Optimizes "for" tag by removing the "loop" variable creation whenever possible.
    #
    #  @param Twig::NodeInterface node A Node
    #  @param Twig_Environment   env  The current Twig environment
    #
    def leave_optimize_for(node, env)
      if node.is_a?(Twig::Node::For)
        array_shift(@loops)
        array_shift(@loopsTargets)
        array_shift(@loopsTargets)
      end
    end

    def add_loop_to_current
      @loops[0].set_attribute('with_loop', true)
    end

    def add_loop_to_all
      @loops.each do |loop|
        loop.set_attribute('with_loop', true)
      end
    end

    def get_priority
      255
    end

  end
end
