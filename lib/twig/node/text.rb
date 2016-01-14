module Twig
  class Node::Text < Twig::Node::Output

    def initialize(data, lineno)
      super(nil, {'data' => data}, lineno)
    end

    def compile(compiler)
      compiler
        .add_debug_info(self)
        .write('_twigout << ')
        .string(get_attribute('data'))
        .raw("\n")
    end

  end
end
