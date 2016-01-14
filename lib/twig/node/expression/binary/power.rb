module Twig
  class Node::Expression::Binary::Power < Twig::Node::Expression::Binary
    def compile(compiler)
      compiler
        .raw('pow(')
        .subcompile(get_node('left'))
        .raw(', ')
        .subcompile(get_node('right'))
        .raw(')')
    end

    def operator(compiler)
      compiler.raw('**')
    end
  end
end
