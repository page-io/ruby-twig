module Twig
  class Node::Expression::Unary::Neg < Node::Expression::Unary

    def operator(compiler)
      compiler.raw('-')
    end

  end
end
