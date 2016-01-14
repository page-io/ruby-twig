module Twig
  class Node::Expression::Binary::Sub < Twig::Node::Expression::Binary
    def operator(compiler)
      compiler.raw('-')
    end
  end
end
