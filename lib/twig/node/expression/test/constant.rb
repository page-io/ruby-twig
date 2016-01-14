module Twig

  # Checks if a variable is the exact same value as a constant.
  #
  # <pre>
  #  {% if post.status is constant('Post::PUBLISHED') %}
  #    the status attribute is exactly the same as Post::PUBLISHED
  #  {% endif %}
  # </pre>
  class Node::Expression::Test::Constant < Twig::Node::Expression::Test
    def compile(compiler)
      compiler
        .raw('(')
        .subcompile(get_node('node'))
        .raw(' == constant(')

      if get_node('arguments').nodes[1]
        compiler
          .raw('(')
          .subcompile(get_node('arguments').nodes[1])
          .raw(').class.name+"::"+')
      end

      compiler
        .subcompile(get_node('arguments').nodes[0])
        .raw('))')
    end
  end
end
