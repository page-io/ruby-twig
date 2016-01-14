module Twig
  class Node::AutoEscape < Twig::Node

    def initialize(value, body, lineno, tag = 'autoescape')
      super({:body => body}, {'value' => value}, lineno, tag)
    end

    def compile(compiler)
      compiler.subcompile(get_node(:body))
    end

  end
end
