module Twig
  class Node::SetTemp < Twig::Node

    def initialize(name, lineno)
      super(nil, {'name' => name}, lineno)
    end

    def compile(compiler)
        name = get_attribute('name')
        compiler
          .add_debug_info(self)
          .write('if (isset($context[')
          .string(name)
          .raw('])) { $_')
          .raw(name)
          .raw('_ = $context[')
          .repr(name)
          .raw(']; else $_')
          .raw(name)
          .raw("_ = null; }\n")
    end
  end
end
