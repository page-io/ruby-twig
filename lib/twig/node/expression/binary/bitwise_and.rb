module Twig
  class Node::Expression::Binary::BitwiseAnd < Twig::Node::Expression::Binary
    def operator(compiler)
      compiler.raw('&')
    end
  end
end
