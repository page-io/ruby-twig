module Twig
  # Checks if a variable is defined in the current context.
  #
  # <pre>
  # {# defined works with variable names and variable attributes #}
  # {% if foo is defined %}
  #     {# ... #}
  # {% endif %}
  # </pre>
  class Node::Expression::Test::Defined < Twig::Node::Expression::Test
    def initialize(node, name, arguments, lineno)
      super(node, name, arguments, lineno)

      if node.is_a?(Twig::Node::Expression::Name)
        node.set_attribute(:is_defined_test, true)
      elsif node.is_a?(Twig::Node::Expression::GetAttr)
        node.set_attribute(:is_defined_test, true)

        change_ignore_strict_check(node)
      else
        raise Twig::Error::Syntax.new('The "defined" test only works with simple variables.', lineno)
      end
    end

    def change_ignore_strict_check(node)
      node.set_attribute(:ignore_strict_check, true)

      if node.get_node('node').is_a?(Twig::Node::Expression::GetAttr)
        change_ignore_strict_check(node.get_node('node'))
      end
    end

    def compile(compiler)
      compiler.subcompile(get_node('node'))
    end
  end
end
