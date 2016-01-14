module Twig
  class Node::Embed < Twig::Node::Include
    # we don't inject the module to avoid node visitors to traverse it twice (as it will be already visited in the main module)
    def initialize(filename, index, variables = nil, only = false, ignore_missing = false, lineno = -1, tag = nil)
      initialize(Twig::Node::Expression::Constant.new('not_used', lineno), variables, only, ignore_missing, lineno, tag)
      set_attribute('filename', filename)
      set_attribute('index', index)
    end

    def add_get_template(compiler)
      compiler.
        write('load_template(').
        string(get_attribute('filename')).
        raw(', ').
        repr(compiler.filename).
        raw(', ').
        repr(lineno).
        raw(', ').
        string(get_attribute('index')).
        raw(')')
    end
  end
end
