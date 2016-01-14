module Twig
  class Node::Expression::GetAttr < Node::Expression

    def initialize(node, attribute, arguments, type, lineno)
      super(
        {
          'node' => node,
          'attribute' => attribute,
          'arguments' => arguments
        },
        {
          type: type,
          is_defined_test: false,
          ignore_strict_check: false,
          disable_c_ext: false
        },
        lineno)
    end

    def compile(compiler)
      # if (respond_to?(:twig_template_get_attributes) && !get_attribute(:disable_c_ext))
      #   compiler.raw('twig_template_get_attributes(self, ')
      # else
        compiler.raw('get_attribute(')
      # end
      if get_attribute(:ignore_strict_check)
        get_node('node').set_attribute(:ignore_strict_check, true)
      end

      compiler.subcompile(get_node('node'))

      compiler.raw(', ').subcompile(get_node('attribute'))

      # only generate optional arguments when needed (to make generated code more readable)
      need_fourth = get_attribute(:ignore_strict_check)
      need_third = need_fourth || get_attribute(:is_defined_test)
      need_second = need_third || :any_call != get_attribute(:type)
      need_first = need_second || !get_node('arguments').nil?

      if need_first
        if get_node('arguments')
          compiler.raw(', ').subcompile(get_node('arguments'))
        else
          compiler.raw(', []')
        end
      end

      if need_second
        compiler.raw(', ').repr(get_attribute(:type))
      end

      if need_third
        compiler.raw(', ').repr(get_attribute(:is_defined_test))
      end

      if need_fourth
        compiler.raw(', ').repr(get_attribute(:ignore_strict_check))
      end

      compiler.raw(')')
    end

  end
end
