module Twig
  class Node::Expression::Binary::Div < Twig::Node::Expression::Binary
    def operator(compiler)
      compiler.raw('/')
    end
  end
end
