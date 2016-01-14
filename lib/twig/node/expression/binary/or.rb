module Twig
  class Node::Expression::Binary::Or < Twig::Node::Expression::Binary
    def operator(compiler)
      compiler.raw('||')
    end
  end
end
