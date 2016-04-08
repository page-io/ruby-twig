module Twig
  class Node::Expression::Binary::Filter::Default < Twig::Node::Expression::Filter

    def initialize(node, filter_name, arguments, nodelineno, tag = nil)
      default = Twig::Node::Expression::Filter.new(node, Twig::Node::Expression::Constant.new('default', nodelineno), arguments, nodelineno)

      if ('default' == filter_name.get_attribute('value')) && node.is_a?(Twig::Node::Expression::Name) || node.is_a?(Twig::Node::Expression::GetAttr)
        node_test = Twig::Node::Expression::Test::Defined.new(node.dup, 'defined', Twig::Node.new, nodelineno)
        node_false = arguments ? arguments.nodes[0] : Twig::Node::Expression::Constant.new('', nodelineno)

        node = Twig::Node::Expression::Conditional.new(node_test, default, node_false, nodelineno)
      else
        node = default
      end

      super(node, filter_name, arguments, lineno, tag)
    end

    def compile(compiler)
      compiler.subcompile(get_node('node'))
    end
  end
end
