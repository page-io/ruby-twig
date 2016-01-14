module Twig
  class Node::Expression::Unary < Node::Expression

    def initialize(node, lineno)
      super({'node' => node}, nil, lineno)
    end

    def compile(compiler)
        compiler.raw(' ')
        operator(compiler)
        compiler.subcompile(get_node('node'))
    end

    #     abstract public function operator(compiler);

  end
end
