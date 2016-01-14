module Twig
  class Node::Expression::Binary::Less < Twig::Node::Expression::Binary
    def operator(compiler)
      compiler.raw('<')
    end
  end
end
