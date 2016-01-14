module Twig
  class Node::Expression::Binary::Add < Twig::Node::Expression::Binary
    def operator(compiler)
      compiler.raw('+')
    end
  end
end
