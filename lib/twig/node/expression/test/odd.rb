module Twig

  # Checks if a number is odd.
  #
  # <pre>
  #  {{ var is odd }}
  # </pre>
  #
  class Node::Expression::Test::Odd < Twig::Node::Expression::Test
    def compile(compiler)
      compiler
        .raw('(')
        .subcompile(get_node('node'))
        .raw(' % 2 == 1')
        .raw(')')
    end
  end
end
