module Twig

  class Node::If < Twig::Node
    def initialize(tests, _else, lineno, tag = nil)
      super({ tests: tests, else: _else }, nil, lineno, tag)
    end

    def compile(compiler)
      compiler.add_debug_info(self)
      count = get_node(:tests).length

      (0..count-1).step(2).each do |i|
        if (i > 0)
          compiler
            .outdent
            .write('elsif ')
        else
          compiler.write('if ')
        end
        compiler
          .subcompile(get_node(:tests).nodes[i])
          .raw("\n")
          .indent
          .subcompile(get_node(:tests).nodes[i + 1])
      end

      if get_node(:else)
        compiler
          .outdent
          .write("else\n")
          .indent
          .subcompile(get_node(:else))
      end

      compiler
        .outdent
        .write("end\n")
    end
  end
end
