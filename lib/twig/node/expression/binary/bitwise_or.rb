module Twig
  class Node::Expression::Binary::BitwiseOr < Twig::Node::Expression::Binary
    def operator(compiler)
      compiler.raw('|')
    end
  end
end
