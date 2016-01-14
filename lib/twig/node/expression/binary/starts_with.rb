module Twig
  class Node::Expression::Binary::StartsWith < Twig::Node::Expression::Binary
    def compile(compiler)
      left = compiler.getVarName();
      right = compiler.getVarName();
      compiler
        .raw(sprintf('(is_string($%s = ', left))
        .subcompile(get_node('left'))
        .raw(sprintf(') && is_string($%s = ', right))
        .subcompile(get_node('right'))
        .raw(sprintf(') && (\'\' == $%2$s || 0 == strpos($%1$s, $%2$s)))', left, right))
    end

    def operator(compiler)
      compiler.raw('')
    end
  end
end
