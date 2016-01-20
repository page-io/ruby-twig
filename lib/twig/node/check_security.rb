module Twig
  class Node::CheckSecurity < Twig::Node

#     protected $usedFilters;
#     protected $usedTags;
#     protected $usedFunctions;

    def initialize(used_filters, used_tags, used_dunctions)
        @usedFilters = used_filters
        @usedTags = used_tags
        @usedFunctions = used_functions
        super
    end

    def compile(compiler)
      tags = {}
      filters = {}
      functions = {}

      ['tags', 'filters', 'functions'].each do |type|
        if node.is_a?(Twig::Node)
          type[name] = node.lineno
        end
      end

      compiler
        .write('_tags = ').repr(tags.value).raw(";\n")
        .write('_filters = ').repr(filters.values).raw(";\n")
        .write('_functions = ').repr(functions.values).raw(";\n\n")
        .write("begin\n")
        .indent
        .write("@env.get_extension('sandbox').check_security(\n")
        .indent
        .write(!tags ? "[],\n" : "['"+tags.keys.join("','")+"'],\n")
        .write(!filters ? "[],\n" : "['"+filters.keys.join("','")+"'],\n")
        .write(!functions ? "[]\n" : "['"+functions.keys.join("','")+"']\n")
        .outdent
        .write(")\n")
        .outdent
        .write("rescue Twig::Sandbox::SecurityError => ex\n")
        .indent
        .write("ex.set_template_file(get_template_name)\n\n")
        .write("if (ex.is_a?(Twig::Sandbox::SecurityNotAllowedTagError) && isset(_tags[ex.get_tag_name]))\n")
        .indent
        .write("ex.set_templateLine(_tags[ex.get_tag_name()])\n")
        .outdent
        .write("elsif (ex.is_a?(Twig::Sandbox::SecurityNotAllowedFilterError) && isset(_filters[ex.get_filter_name]))\n")
        .indent
        .write("ex.set_template_line(_filters[ex.get_filter_name])\n")
        .outdent
        .write("elsif (ex.is_a?(Twig::Sandbox::SecurityNotAllowedFunctionError) && isset(_functions[ex.get_function_name()]))\n")
        .indent
        .write("ex.set_template_line(_functions[ex.get_function_name])\n")
        .outdent
        .write("end\n\n")
        .write("raise\n")
        .outdent
        .write("end\n\n")
    end
  end
end
