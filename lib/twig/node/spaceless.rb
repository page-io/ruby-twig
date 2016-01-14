module Twig
  class Node::Spaceless < Twig::Node

    def initialize(body, lineno, tag = 'spaceless')
      super({:body => body}, nil, lineno, tag)
    end

    def compile(compiler)
      compiler
        .add_debug_info(self)
        .write("_twigout << begin\n")
        .indent
        .write("_twigout = ''\n")
        .subcompile(get_node(:body))
        .write("_twigout.gsub(/>\s+</, '><')\n")
        .outdent
        .write("end\n")
    end

  end
end
