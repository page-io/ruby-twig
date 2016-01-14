module Twig
  class Node::Do < Twig::Node

    def initialize(expr, lineno, tag = nil)
      super({ expr: expr }, nil, lineno, tag)
    end

    def compile(compiler)
      compiler
        .add_debug_info(self)
        .write('')
        .subcompile(get_node(:expr))
        .raw("\n")
    end

  end
end
