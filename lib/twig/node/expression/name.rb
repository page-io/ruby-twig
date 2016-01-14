module Twig
  class Node::Expression::Name < Twig::Node::Expression
    SPECIAL_VARS = {
      '_self' => 'self',
      '_context' => '_context',
      '_charset' => '@env.get_charset'
    }

    def initialize(name, lineno)
      super(nil, {'name' => name, is_defined_test: false, ignore_strict_check: false, always_defined: false}, lineno)
    end

    def compile(compiler)
      name = get_attribute('name')
      compiler.add_debug_info(self)
      if get_attribute(:is_defined_test)
        if is_special
          if '_self' == name
            # @trigger_error(sprintf('Global variable "_self" is deprecated in %s at line %d', '?', $this.lineno), E_USER_DEPRECATED)
          end
          compiler.repr(true)
        else
          compiler.raw('_context.key?(').repr(name).raw(')')
        end
      elsif is_special
        if ('_self' == name)
          # @trigger_error(sprintf('Global variable "_self" is deprecated in %s at line %d', '?', $this.lineno), E_USER_DEPRECATED);
        end
        compiler.raw(SPECIAL_VARS[name])
      elsif get_attribute(:always_defined)
        compiler
          .raw('_context[')
          .string(name)
          .raw(']')
      else
        compiler
          .raw('_context[')
          .string(name)
          .raw(']')
        unless (get_attribute(:ignore_strict_check) || !compiler.environment.is_strict_variables)
          compiler.raw(' || get_context(_context, ').string(name).raw(')')
        end
      end
    end

    def is_special
      SPECIAL_VARS.key?(get_attribute('name'))
    end

    def is_simple
      !is_special && !get_attribute(:is_defined_test)
    end

  end
end
