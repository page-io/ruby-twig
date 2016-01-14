module Twig
  class Node::Expression::Binary::FloorDiv < Twig::Node::Expression::Binary
    def compile(compiler)
      compiler.raw('intval(floor(')
      super(compiler)
      compiler.raw('))')
    end

    def operator(compiler)
      compiler.raw('/')
    end
  end
end
