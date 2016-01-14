module Twig
  # Checks if a variable is divisible by a number.
  #
  # <pre>
  #  {% if loop.index is divisible by(3) %}
  # </pre>
  #
  class Node::Expression::Test::Divisibleby < Twig::Node::Expression::Test
    def compile(compiler)
      compiler
          .raw('(0 == ')
          .subcompile(get_node('node'))
          .raw(' % ')
          .subcompile(get_node('arguments').nodes[0])
          .raw(')')
    end
  end
end
