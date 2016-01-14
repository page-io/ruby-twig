module Twig
  class Node::Expression::Binary::And < Twig::Node::Expression::Binary
    def operator(compiler)
      compiler.raw('&&')
    end
  end
end
