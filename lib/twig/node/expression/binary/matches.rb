module Twig
  class Node::Expression::Binary::Matches < Twig::Node::Expression::Binary
    def compile(compiler)
      compiler
        .raw('preg_match(')
        .subcompile(get_node('right'))
        .raw(', ')
        .subcompile(get_node('left'))
        .raw(')')
    end

    def operator(compiler)
      compiler.raw('')
    end
  end
end
