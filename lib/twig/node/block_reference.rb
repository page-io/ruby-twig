module Twig
  class Node::BlockReference < Twig::Node::Output

    def initialize(name, lineno, tag = nil)
      super(nil, {'name' => name}, lineno, tag)
    end

    def compile(compiler)
      compiler
        .add_debug_info(self)
        .write("_twigout << display_block('#{get_attribute('name')}', _context, blocks)\n")
    end

  end
end
