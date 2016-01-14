module Twig
  class Node::Expression::Constant < Node::Expression

    def initialize(value, lineno)
      super(nil, {'value' => value}, lineno)
    end

    def compile(compiler)
      puts "debug compile: #{self.class.name}"
      compiler.repr(get_attribute('value'))
    end

  end
end
