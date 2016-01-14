module Twig
  class Node::Expression::Unary::Not < Node::Expression::Unary

    def operator(compiler)
      compiler.raw('!')
    end

  end
end
