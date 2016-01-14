module Twig
  class Node::Expression::TempName < Node::Expression

    def initialize(name, lineno)
      super(nil, {'name' => name}, lineno)
    end

    def compile(compiler)
      compiler
        .raw('_')
        .raw(get_attribute('name'))
        .raw('_')
    end

  end
end
