module Twig
  class Node::Module < Twig::Node

    def initialize(body, parent, blocks, macros, traits, embedded_templates, filename)
      # embedded templates are set as attributes so that they are only visited once by the visitors
      super({
          'parent' => parent,
          body: body,
          blocks: blocks,
          macros: macros,
          traits: traits,
          display_start: Twig::Node.new,
          display_end: Twig::Node.new,
          constructor_start: Twig::Node.new,
          constructor_end: Twig::Node.new,
          class_end: Twig::Node.new
        },
        {
          'filename' => filename,
          'index' => nil,
          'embedded_templates' => embedded_templates,
        },
        1
      )
    end

    def set_index(index)
      set_attribute('index', index)
    end

    def compile(compiler)
      compile_template(compiler)

      get_attribute('embedded_templates').each do |template|
        compiler.subcompile(template)
      end
    end

    def compile_template(compiler)
      # if !get_attribute('index')
      #   compiler.write('<?php')
      # end

      compile_class_header(compiler)

      if (
        get_node(:blocks).length ||
        get_node(:traits).length ||
        get_node('parent').nil? ||
        get_node('parent').is_a?(Twig::Node::Expression::Constant) ||
        get_node(:constructor_start).length > 0 ||
        get_node(:constructor_end).length > 0
      )
        compile_constructor(compiler)
      end

      compile_get_parent(compiler)

      compile_display(compiler)

      compiler.subcompile(get_node(:blocks))

      compile_macros(compiler)

      compile_get_template_name(compiler)

      compile_is_traitable(compiler)

      compile_debug_info(compiler)

      compile_class_footer(compiler)
    end

    def compile_get_parent(compiler)
      if !(parent = get_node('parent'))
        return
      end

      compiler
        .write("def do_get_parent(_context)\n")
        .indent
        .add_debug_info(parent)

      if parent.is_a?(Twig::Node::Expression::Constant)
        compiler.
          write('').
          subcompile(parent)
      else
        compiler
          .write('load_template(')
          .subcompile(parent)
          .raw(', ')
          .repr(compiler.filename)
          .raw(', ')
          .repr(get_node('parent').lineno)
          .raw(')')
      end

      compiler
        .raw("\n")
        .outdent
        .write("end\n\n")
    end

    def compile_class_header(compiler)
      compiler
        .write('class ' + compiler.environment.get_template_class(get_attribute('filename'), get_attribute('index')))
        .raw(" < #{compiler.environment.base_template_class}\n")
        .indent
    end

    def compile_constructor(compiler)
      compiler
        .write("def initialize(env)\n")
        .indent
        .subcompile(get_node(:constructor_start))
        .write("super(env)\n")

      # parent
      if !(parent = get_node('parent'))
        compiler.write("@parent = nil\n")
      elsif parent.is_a?(Twig::Node::Expression::Constant)
        compiler
          .add_debug_info(parent)
          .write('@parent = load_template(')
          .subcompile(parent)
          .raw(', ')
          .repr(compiler.filename)
          .raw(', ')
          .repr(get_node('parent').lineno)
          .raw(")\n")
      end

      count_traits = get_node(:traits).length
      if count_traits > 0
        # traits
        get_node(:traits).each do |i, trait|
          compile_load_template(compiler, trait.get_node('template'), "_trait_#{i}")

          compiler
            .add_debug_info(trait.get_node('template'))
            .write("if (!_trait_#{i}.is_traitable())\n")
            .indent
            .write("raise Twig::Error::Runtime.new('Template \"'.")
            .subcompile(trait.get_node('template'))
            .raw(".'\" cannot be used as a trait.')\n")
            .outdent
            .write("end\n")
            .write("_trait_#{i}_blocks = _trait_#{i}.get_blocks\n\n")

          trait.get_node('targets').each do |key, value|
            compiler.
              write("if (!isset($_trait_#{i}_blocks[").
              string(key).
              raw("]))\n").
              indent.
              write("raise Twig::Error::Runtime(sprintf('Block ").
              string(key).
              raw(' is not defined in trait ').
              subcompile(trait.get_node('template')).
              raw(".'))\n").
              outdent.
              write("end\n\n").
              write("_trait_#{i}_blocks[").
              subcompile(value).
              raw("] = _trait_#{i}_blocks[").
              string(key).
              raw("]; unset(_trait_#{i}_blocks[").
              string(key).
              raw("])\n\n")
          end
        end

        if count_traits > 1
          compiler.
            write("_traits = array_merge(\n").
            indent

          (0..count_traits).each do |i|
            compiler.
              write("_trait_#{i}_blocks#{(i == count_traits - 1 ? '' : ',')}.\"\n")
          end

          compiler.
            outdent.
            write(")\n\n")
        else
          compiler
            .write("_traits = _trait_0_blocks\n\n")
        end

        compiler
          .write("@blocks = array_merge(\n")
          .indent
          .write("_traits,\n")
          .write("{\n")
      else
        compiler.write("@blocks = {\n")
      end

      # blocks
      compiler.
        indent

      get_node(:blocks).nodes.each do |name, node|
        compiler.
          write("'#{name}' => [self, 'block_#{name}'],\n")
      end

      if count_traits > 0
        compiler.
          outdent.
          write("}\n")
      end

      compiler.
        outdent.
        write("}\n").
        outdent.
        subcompile(get_node(:constructor_end)).
        write("end\n\n")
    end

    def compile_display(compiler)
      compiler
        .write("def do_display(_context, blocks = [])\n")
        .indent
        .write("_twigout = []\n")
        .subcompile(get_node(:display_start))
        .subcompile(get_node(:body))

      if (parent = get_node('parent'))
        compiler.add_debug_info(parent)

        compiler.write('_twigout << ')
        if parent.is_a?(Twig::Node::Expression::Constant)
          compiler.raw('@parent')
        else
          compiler.raw('get_parent(_context)')
        end
        compiler.raw(".display(_context, @blocks.merge(blocks))\n")
      end

      compiler.
        write("_twigout.join\n").
        subcompile(get_node(:display_end)).
        outdent.
        write("end\n\n")
    end

    def compile_class_footer(compiler)
      compiler
        .subcompile(get_node(:class_end))
        .outdent
        .write("end\n")
    end

    def compile_macros(compiler)
      compiler.subcompile(get_node(:macros))
    end

    def compile_get_template_name(compiler)
      compiler
        .write("def get_template_name\n")
        .indent
        .write('')
        .repr(get_attribute('filename'))
        .raw("\n")
        .outdent
        .write("end\n\n")
    end

    def compile_is_traitable(compiler)
      # A template can be used as a trait if:
      #   * it has no parent
      #   * it has no macros
      #   * it has no body
      #
      # Put another way, a template can be used as a trait if it
      # only contains blocks and use statements.

      traitable = (get_node('parent').nil? && (get_node(:macros).length == 0))
      if traitable
        if get_node(:body).is_a?(Twig::Node::Body)
          nodes = get_node(:body).nodes[0]
        else
          nodes = get_node(:body)
        end

        if nodes.length > 0
          nodes = Twig::Node.new([nodes])
        end

        nodes.each do |node|
          if !node.length
            next
          end

          if node.is_a?(Twig::Node::Text) && ctype_space(node.get_attribute('data'))
            next
          end

          if node.is_a?(Twig::Node::BlockReference)
            next
          end

          traitable = false
          break
        end
      end

      if traitable
        return
      end

      compiler
        .write("def is_traitable\n")
        .indent
        .write("#{traitable ? 'true' : 'false'}\n")
        .outdent
        .write("end\n\n")
    end

    def compile_debug_info(compiler)
      compiler
        .write("def get_debug_info\n")
        .indent
        .write(compiler.get_debug_info.to_s.gsub("\n", ''))
        .raw("\n")
        .outdent
        .write("end\n")
    end

    def compile_load_template(compiler, node, _var)
      if node.is_a?(Twig::Node::Expression::Constant)
        compiler
          .write("#{_var} = load_template(")
          .subcompile(node)
          .raw(', ')
          .repr(compiler.filename)
          .raw(', ')
          .repr(node.lineno)
          .raw(")\n")
      else
        raise LogicException.new('Trait templates can only be constant nodes')
      end
    end

  end
end
