module Twig

  # Checks if a number is even.
  #
  # <pre>
  #  {{ var is even }}
  # </pre>
  #
  class Node::Expression::Test::Even < Twig::Node::Expression::Test
    def compile(compiler)
      compiler
          .raw('(')
          .subcompile(get_node('node'))
          .raw(' % 2 == 0')
          .raw(')')
    end
  end
end
