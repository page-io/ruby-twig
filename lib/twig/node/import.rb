module Twig
  class Node::Import < Twig::Node

    def initialize(expr, var, lineno, tag = nil)
      super({:expr => expr, 'var' => var}, nil, lineno, tag)
    end

    def compile(compiler)
      compiler
        .add_debug_info(self)
        .write('')
        .subcompile(get_node('var'))
        .raw(' = ')

      if (get_node(:expr).is_a?(Twig::Node::Expression::Name) && '_self' == get_node(:expr).get_attribute('name'))
        compiler.raw('self')
      else
        compiler
          .raw('load_template(')
          .subcompile(get_node(:expr))
          .raw(', ')
          .repr(compiler.filename)
          .raw(', ')
          .repr(lineno)
          .raw(')')
      end

      compiler.raw("\n")
    end
  end
end
