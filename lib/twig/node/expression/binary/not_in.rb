module Twig
  class Node::Expression::Binary::NotIn < Twig::Node::Expression::Binary

    def compile(compiler)
      compiler
        .raw('!Twig::Runtime.twig_in_filter(')
        .subcompile(get_node('left'))
        .raw(', ')
        .subcompile(get_node('right'))
        .raw(')')
    end

    def operator(compiler)
        return compiler.raw('not in')
    end
  end
end
