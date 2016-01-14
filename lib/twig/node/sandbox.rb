module Twig
  class Node::Sandbox < Twig::Node

    def initialize(body, lineno, tag = nil)
      super({:body => body}, nil, lineno, tag)
    end

    def compile(compiler)
      compiler
        .add_debug_info(self)
        .write("_sandbox = @env.get_extension('sandbox')\n")
        .write("unless _already_sandboxed = _sandbox.is_sandboxed\n")
        .indent
        .write("_sandbox.enable_sandbox\n")
        .outdent
        .write("end\n")
        .subcompile(get_node(:body))
        .write("unless _already_sandboxed\n")
        .indent
        .write("_sandbox.disable_sandbox\n")
        .outdent
        .write("end\n")
    end

  end
end
