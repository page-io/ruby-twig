module Twig
  class Node::Set < Twig::Node

    def initialize(capture, names, values, lineno, tag = nil)
      super(
        {
          'names' => names,
          'values' => values
        },
        {
          capture: capture,
          safe: false
        },lineno, tag
      )

      #
      # Optimizes the node when capture is used for a large block of text.
      #  {% set foo %}foo{% endset %} is compiled to _context['foo'] = Twig::Markup.new("foo");
      if get_attribute(:capture)
        set_attribute(:safe, true)

        values = get_node('values')
        if values.is_a?(Twig::Node::Text)
          set_node('values', Twig::Node::Expression::Constant.new(values.get_attribute('data'), values.lineno))
          set_attribute(:capture, false)
        end
      end
    end

    def compile(compiler)
      compiler.add_debug_info(self)
      if get_node('names').length > 1
        get_node('names').nodes.each_with_index do |node, idx|
          if idx > 0
            compiler.raw(',')
          end
          compiler.subcompile(node)
        end
      else
        compiler.subcompile(get_node('names'), false)

        if get_attribute(:capture)
          compiler.raw(" = begin\n")
            .indent
            .write("_twigout = ''\n")
            .subcompile(get_node('values'))
            .write("_twigout\n")
            .outdent
            .write("end\n")
        end
      end

      unless get_attribute(:capture)
        compiler.raw(' = ')

        if get_node('names').length > 1
          compiler.write('[')
          get_node('values').nodes.each_with_index do |value,index|
            if index > 0
              compiler.raw(',')
            end

            compiler.subcompile(value)
          end
          compiler.raw(']')
        else
          if get_attribute(:safe)
            compiler
              .subcompile(get_node('values'))
          else
            compiler.subcompile(get_node('values'))
          end
        end
      end

      compiler.raw("\n")
    end
  end
end
