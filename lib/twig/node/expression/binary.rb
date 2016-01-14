module Twig
  class Node::Expression::Binary < Node::Expression

    def initialize(left, right, lineno)
      super({'left' => left, 'right' => right}, nil, lineno)
    end

    def compile(compiler)
      compiler
        .raw('(')
        .subcompile(get_node('left'))
        .raw(' ')
      operator(compiler)
      compiler
        .raw(' ')
        .subcompile(get_node('right'))
        .raw(')')
    end

  end
end
