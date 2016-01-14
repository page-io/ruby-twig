module Twig
  class Node::Expression::Array < Node::Expression

    # protected $index;

    def initialize(elements, lineno)
      super(elements, nil, lineno)
    end

    def add_element(value)
      @nodes << value
    end

    def compile(compiler)
      compiler.raw('[')
      _first = true
      @nodes.each do |node|
        if !_first
          compiler.raw(',')
        end
        _first = false
        compiler
          .subcompile(node)
      end
      compiler.raw(']')
    end

  end
end
