module Twig
  class Node::Expression::Binary::Mod < Twig::Node::Expression::Binary
    def operator(compiler)
      compiler.raw('%')
    end
  end
end
