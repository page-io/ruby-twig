module Twig

  # Checks if a variable is the same as another one (== in PHP).
  #
  class Node::Expression::Test::Sameas < Twig::Node::Expression::Test
    def compile(compiler)
      compiler
        .raw('(')
        .subcompile(get_node('node'))
        .raw(' == ')
        .subcompile(get_node('arguments').nodes[0])
        .raw(')')
    end
  end
end
