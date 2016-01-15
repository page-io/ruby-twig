module Twig
  class Node::Expression::Binary::Concat < Twig::Node::Expression::Binary

    def compile(compiler)
      compiler
        .raw('(')
        .subcompile(get_node('left'))
        .raw('.to_s + ')
        .subcompile(get_node('right'))
        .raw('.to_s)')
    end

    def operator(compiler)
      compiler.raw('+')
    end
  end
end
