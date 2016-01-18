module Twig
  class Node::Expression::Constant < Node::Expression

    def initialize(value, lineno)
      super(nil, {'value' => value}, lineno)
    end

    def compile(compiler)
      compiler.repr(get_attribute('value'))
    end

  end
end
