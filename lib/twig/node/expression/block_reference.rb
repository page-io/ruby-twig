module Twig
  class Node::Expression::BlockReference < Node::Expression

    def initialize(name, as_string, lineno, tag = nil)
      super({'name' => name}, {'as_string' => as_string, 'output' => false}, lineno, tag)
    end

    def compile(compiler)
      if get_attribute('output')
        compiler
          .add_debug_info(self)
          .write('display_block(')
          .subcompile(get_node('name'))
          .raw(", _context, @blocks)\n")
      else
        compiler
          .raw('render_block(')
          .subcompile(get_node('name'))
          .raw(', _context, @blocks)')
      end
      if get_attribute('as_string')
        compiler.raw('.to_s ')
      end
    end

  end
end
