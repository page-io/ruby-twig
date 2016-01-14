module Twig
  class Node::Expression::Binary::Concat < Twig::Node::Expression::Binary
    def operator(compiler)
      compiler.raw('+')
    end
  end
end
