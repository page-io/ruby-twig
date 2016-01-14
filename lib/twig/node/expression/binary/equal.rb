module Twig
  class Node::Expression::Binary::Equal < Twig::Node::Expression::Binary
    def operator(compiler)
      compiler.raw('==')
    end
  end
end
