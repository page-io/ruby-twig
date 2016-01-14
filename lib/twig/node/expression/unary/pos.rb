module Twig
  class Node::Expression::Unary::Pos < Node::Expression::Unary

    def operator(compiler)
      compiler.raw('+')
    end

  end
end
