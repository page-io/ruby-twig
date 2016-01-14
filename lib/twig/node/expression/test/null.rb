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
        .raw('(nil == ')
        .subcompile(get_node('node'))
        .raw(')')
    end
  end
end
