module Twig
  class Node::Expression::Binary::Mul < Twig::Node::Expression::Binary
    def operator(compiler)
      compiler.raw('*')
    end
  end
end
