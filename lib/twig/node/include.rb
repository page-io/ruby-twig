module Twig
  class Node::Include < Twig::Node::Output

    def initialize(expr, variables, only, ignore_missing, lineno, tag = nil)
      super({:expr => expr, variables: variables}, { only: only, ignore_missing: ignore_missing }, lineno, tag)
    end

    def compile(compiler)
      compiler.add_debug_info(self)

      if get_attribute(:ignore_missing)
        compiler
          .write("begin\n")
          .indent
      end

      add_get_template(compiler)

      compiler.raw('.display(')

      add_template_arguments(compiler)

      compiler.raw(")\n");

      if get_attribute(:ignore_missing)
        compiler
          .outdent
          .write("rescue Twig::Error::Loader\n")
          .indent
          .write("# ignore missing template\n")
          .outdent
          .write("end\n\n")
      end
    end

    def add_get_template(compiler)
      compiler
        .write('_twigout << load_template(')
        .subcompile(get_node(:expr))
        .raw(',')
        .repr(compiler.get_filename)
        .raw(',')
        .repr(lineno)
        .raw(')')
    end

    def add_template_arguments(compiler)
      if get_node(:variables).nil?
        compiler.raw(!get_attribute(:only) ? '_context' : '{}')

      elsif !get_attribute(:only)
        compiler
          .raw('_context.merge(')
          .subcompile(get_node(:variables))
          .raw(')')

      else
        compiler.subcompile(get_node(:variables))
      end
    end
  end
end
