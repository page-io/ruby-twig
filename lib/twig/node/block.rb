module Twig
  class Node::Block < Twig::Node

    def initialize(name, body, lineno, tag = nil)
      super({:body => body}, {'name' => name}, lineno, tag)
    end

    def compile(compiler)
      compiler
        .add_debug_info(self)
        .write("def block_#{get_attribute('name')}(_context, blocks = [])\n")
        .indent
        .write("_twigout = ''\n")
      compiler
        .subcompile(get_node(:body))
        .write("_twigout\n")
        .outdent
        .write("end\n\n")
    end
  end
end
