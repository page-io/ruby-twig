module Twig
  class Node::Expression::Binary::Range < Twig::Node::Expression::Binary

    def compile(compiler)
      compiler
        .raw('range(')
        .subcompile(get_node('left'))
        .raw(', ')
        .subcompile(get_node('right'))
        .raw(')')
    end

    def operator(compiler)
      compiler.raw('..')
    end
  end
end
