module Twig
  class Node::Expression::Binary::GreaterEqual < Twig::Node::Expression::Binary
    def operator(compiler)
      compiler.raw('>=')
    end
  end
end
