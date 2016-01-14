module Twig
  class Node::Expression::Binary::Filter::Default < Twig::Node::Expression::Filter

    def initialize(node, filter_name, arguments, lineno, tag = nil)
      default = Twig::Node::Expression::Filter.new(node, Twig::Node::Expression::Constant.new('default', nodelineno), arguments, nodelineno)

      if ('default' == filter_name.get_attribute('value')) && node.is_a?(Twig::Node::Expression::Name) || node.is_a?(Twig::Node::Expression::GetAttr)
        _test = Twig::Node::Expression::Test::Defined.new(node.dupe, 'defined', Twig::Node.new, nodelineno)
        _false = count(arguments) ? arguments.nodes[0] : Twig::Node::Expression::Constant.new('', nodelineno)

        node = Twig::Node::Expression::Conditional.new(_test, default, _false, nodelineno)
      else
        node = default
      end

      super(node, filter_name, arguments, lineno, tag);
    end

    def compile(compiler)
      compiler.subcompile(get_node('node'))
    end
  end
end
