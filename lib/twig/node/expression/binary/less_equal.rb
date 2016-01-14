module Twig
  class Node::Expression::Binary::LessEqual < Twig::Node::Expression::Binary
    def operator(compiler)
      compiler.raw('<=')
    end
  end
end
