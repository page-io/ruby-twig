module Twig
  class Node::Expression::Binary::Greater < Twig::Node::Expression::Binary
    def operator(compiler)
      compiler.raw('>')
    end
  end
end
