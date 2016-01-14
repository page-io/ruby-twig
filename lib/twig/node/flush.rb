module Twig
  class Node::Flush < Twig::Node

    def initialize(lineno, tag)
      super(nil, nil, lineno, tag)
    end

    def compile(compiler)
      compiler
        .add_debug_info(self)
        .write("flush();\n")
    end

  end
end
