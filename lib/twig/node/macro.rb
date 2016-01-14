module Twig
  class Node::Macro < Twig::Node

    VARARGS_NAME = 'varargs'

    def initialize(name, body, arguments, lineno, tag = nil)
      arguments.each do |argument_name, argument|
        if (VARARGS_NAME == argument_name)
          raise Twig::Error::Syntax.new("The argument \"#{VARARGS_NAME}}\" in macro \"#{name}\" cannot be defined because the variable \"#{VARARGS_NAME}\" is reserved for arbitrary arguments.", argument.lineno)
        end
      end

      super({:body => body, 'arguments' => arguments}, {'name' => name}, lineno, tag)
    end

    def compile(compiler)
      compiler
        .add_debug_info(self)
        .write("def get#{get_attribute('name')}(")

      count = get_node('arguments').length
      pos = 0
      get_node('arguments').nodes.each do |name, default|
        compiler
          .raw("__#{name}__ = ")
          .subcompile(default)
          pos = pos + 1
          if (pos < count)
            compiler.raw(', ')
          end
      end

      if count > 0
        compiler.raw(', ');
      end

      compiler.raw('__varargs__')

      compiler
        .raw(")\n")
        .indent

      compiler
        .write("_context = @env.merge_globals({\n")
        .indent

      get_node('arguments').nodes.each do |name, default|
        compiler
          .add_indentation
          .string(name)
          .raw(" => __#{name}__")
          .raw(",\n")
      end

      compiler
        .add_indentation
        .string(VARARGS_NAME)
        .raw(' => ')

      compiler.raw("__varargs__\n");

      compiler
        .outdent
        .write("})\n")
        .write("blocks = []\n")
        .write("begin\n")
        .indent
        .subcompile(get_node(:body))
        .outdent
        .write("rescue => ex\n")
        .indent
        .write("raise\n")
        .outdent
        .write("end\n")
        .write("(_twigout.length > 0 ? Twig::Markup.new(_twigout, @env.get_charset) : '')\n")
        .outdent
        .write("end\n")
    end
  end
end
