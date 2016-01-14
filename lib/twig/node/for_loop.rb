module Twig
  class Node::ForLoop < Twig::Node

    def initialize(lineno, tag = nil)
      super(nil, { with_loop: false, ifexpr: false, else: false }, lineno, tag)
    end

    def compile(compiler)
      if get_attribute(:else)
        compiler.write("_context['_iterated'] = true\n")
      end

      if get_attribute(:with_loop)
        compiler
          .write("_context['loop']['index0'] += 1\n")
          .write("_context['loop']['index'] += 1\n")
          .write("_context['loop']['first'] = false\n")

        if !get_attribute(:ifexpr)
          compiler
            .write("if _context['loop'].key?('length')\n")
            .indent
            .write("_context['loop']['revindex0'] -= 1\n")
            .write("_context['loop']['revindex'] -= 1\n")
            .write("_context['loop']['last'] = 0 == _context['loop']['revindex0']\n")
            .outdent
            .write("end\n")
        end
      end
    end
  end
end
