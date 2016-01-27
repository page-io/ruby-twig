module Twig
  class Node::For < Twig::Node

    def initialize(key_target, value_target, seq, ifexpr, body, _else, lineno, tag = nil)

      @loop = Twig::Node::ForLoop.new(lineno, tag)

      body = Twig::Node.new([body, @loop])

      unless ifexpr.nil?
        body = Twig::Node::If.new(Twig::Node.new([ifexpr, body]), nil, lineno, tag)
      end

      super({ key_target: key_target, value_target: value_target, seq: seq, body: body, else: _else}, { with_loop: true, ifexpr: !ifexpr.nil?}, lineno, tag)
    end

    def compile(compiler)
      compiler
        .add_debug_info(self)
        .write("_context['_parent'] = {}.merge(_context)\n")
        .write("_context['_seq'] = ")
        .subcompile(get_node(:seq))
        .raw("\n")

      unless get_node(:else).nil?
        compiler.write("_context['_iterated'] = false\n");
      end

      if get_attribute(:with_loop)
        compiler
          .write("_context['loop'] = {\n")
          .indent
            .write("'parent' => _context['_parent'],\n")
            .write("'index0' => 0,\n")
            .write("'index'  => 1,\n")
            .write("'first'  => true,\n")
          .outdent
          .write("}\n")

        if !get_attribute(:ifexpr)
          compiler
            .write("if _context['_seq'].respond_to?(:length)\n")
            .indent
              .write("_length = _context['_seq'].length\n")
              .write("_context['loop']['revindex0'] = _length - 1\n")
              .write("_context['loop']['revindex'] = _length\n")
              .write("_context['loop']['length'] = _length\n")
              .write("_context['loop']['last'] = 1 == _length\n")
            .outdent
            .write("end\n")
        end
      end

      @loop.set_attribute(:else, !get_node(:else).nil?)
      @loop.set_attribute(:with_loop, get_attribute(:with_loop))
      @loop.set_attribute(:ifexpr, get_attribute(:ifexpr))

      compiler.
        write("_context['_seq'].each do |_loop_var|\n").
        indent.
        write('')
      if get_node(:key_target)
        compiler.
          subcompile(get_node(:key_target)).
          raw(',')
      end
      compiler.
        subcompile(get_node(:value_target)).
        raw(" = _loop_var\n").
        subcompile(get_node(:body)).
        outdent.
        write("end\n")

      unless get_node(:else).nil?
        compiler
          .write("unless _context['_iterated']\n")
          .indent
          .subcompile(get_node(:else))
          .outdent
          .write("end\n")
      end

      compiler.write("_parent = _context.delete('_parent')\n")
      # # remove some "private" loop variables (needed for nested loops)
      compiler.write("_context.delete('_seq')\n")
      compiler.write("_context.delete('_iterated')\n")
      compiler.write("_context.delete('#{get_node(:value_target).get_attribute('name')}')\n")
      compiler.write("_context.delete('loop')\n")
      # keep the values set in the inner context for variables defined in the outer context
      compiler.write("_context = _parent\n")

    end
  end
end
