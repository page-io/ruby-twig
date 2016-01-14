module Twig
  class Node::Expression::Conditional < Node::Expression

    def initialize(expr1, expr2, expr3, lineno)
      super({'expr1' => expr1, 'expr2' => expr2, 'expr3' => expr3}, nil, lineno)
    end

    def compile(compiler)
      compiler
        .raw('((')
        .subcompile(get_node('expr1'))
        .raw(') ? (')
        .subcompile(get_node('expr2'))
        .raw(') : (')
        .subcompile(get_node('expr3'))
        .raw('))')
    end

  end
end
