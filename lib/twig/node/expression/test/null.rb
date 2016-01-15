module Twig

  # Checks that a variable is null.
  #
  # <pre>
  #  {{ var is none }}
  # </pre>
  #
  class Node::Expression::Test::Null < Twig::Node::Expression::Test
    def compile(compiler)
      compiler
        .raw('(')
        .subcompile(get_node('node'))
        .raw(').nil?')
    end
  end
end
