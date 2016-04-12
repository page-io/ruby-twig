module Twig
  class Node::Spaceless < Twig::Node

    def initialize(body, lineno, tag = 'spaceless')
      super({:body => body}, nil, lineno, tag)
    end

    def compile(compiler)
      compiler
        .add_debug_info(self)
        .write("_twigout << [].tap{ |_twigout| \n")
        .indent
        .subcompile(get_node(:body))
        .outdent
        .write("}.join.gsub(/>\\s+</, '><')\n")
    end

  end
end
