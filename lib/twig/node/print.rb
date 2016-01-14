module Twig
  class Node::Print < Twig::Node::Output

    def initialize(expr, lineno, tag = nil)
      super({:expr => expr}, nil, lineno, tag)
    end

    def compile(compiler)
      compiler
        .add_debug_info(self)
        .write('_twigout << ')
        .subcompile(get_node(:expr))
        .raw(".to_s\n")
    end

  end
end
