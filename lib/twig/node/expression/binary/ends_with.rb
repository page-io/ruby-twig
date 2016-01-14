module Twig
  class Node::Expression::Binary::EndsWith < Twig::Node::Expression::Binary
    def compile(compiler)
      left = compiler.get_var_name
      right = compiler.get_var_name
      compiler
        .raw(sprintf('(is_string($%s = ', left))
        .subcompile(get_node('left'))
        .raw(sprintf(') && is_string($%s = ', right))
        .subcompile(get_node('right'))
        .raw(sprintf(') && (\'\' == $%2$s || $%2$s == substr($%1$s, -strlen($%2$s))))', left, right))
    end

    def operator(compiler)
      compiler.raw('')
    end
  end
end
