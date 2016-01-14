module Twig
  class Node::Expression::Binary::NotEqual < Twig::Node::Expression::Binary
    def operator(compiler)
      compiler.raw('!=')
    end
  end
end
