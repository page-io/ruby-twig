module Twig
  class Node::Expression::Parent < Node::Expression

    def initialize(name, lineno, tag = nil)
      super(nil, {'output' => false, 'name' => name}, lineno, tag)
    end

    def compile(compiler)
      if (get_attribute('output'))
        compiler
          .add_debug_info(self)
          .write('display_parent_block(')
          .string(get_attribute('name'))
          .raw(", _context, blocks);\n")
      else
        compiler
          .raw('render_parent_block(')
          .string(get_attribute('name'))
          .raw(', _context, blocks)')
      end
    end

  end
end
