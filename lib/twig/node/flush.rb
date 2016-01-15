module Twig
  class Node::Flush < Twig::Node

    def initialize(lineno, tag)
      super(nil, nil, lineno, tag)
    end

    def compile(compiler)
      # not suported
    end

  end
end
