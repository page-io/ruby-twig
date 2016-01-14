module Twig
  class Node::Expression::Binary::BitwiseXor < Twig::Node::Expression::Binary
    def operator(compiler)
      compiler.raw('^')
    end
  end
end
