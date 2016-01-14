module Twig
  class Node::Expression::AssignName < Node::Expression::Name

    # Compiles the node to PHP.
    #
    # @param Twig::Compiler compiler A Twig::Compiler instance
    def compile(compiler)
      compiler.
        raw('_context[').
        string(get_attribute('name')).
        raw(']')
    end
  end
end
