module Twig
  #
  # Represents a template function.
  #
  class SimpleFunction

    attr_accessor :arguments
    attr_reader :name

    def initialize(name, callable, options = {})
      @name = name;
      @callable = callable
      @options = {
        needs_environment: false,
        needs_context: false,
        is_variadic: false,
        # is_safe: nil,
        # is_safe_callback: nil,
        node_class: Twig::Node::Expression::Function,
        deprecated: false,
        # alternative: nil # default
      }.merge(options)
      @arguments = []
    end

    def get_name
      @name
    end

    def get_callable
      @callable
    end

    def get_node_class
      @options[:node_class]
    end

    def needs_environment?
      !!@options[:needs_environment]
    end

    def needs_context?
      !!@options[:needs_context]
    end

    def get_safe(function_args)
      if @options[:is_safe]
        return @options[:is_safe]
      end
      if @options[:is_safe_callback]
        # TODO! check this
        return call_user_func(@options[:is_safe_callback], function_args)
      end
      []
    end

    def is_variadic
      @options[:is_variadic]
    end

    def is_deprecated
      @options[:deprecated]
    end

    def get_alternative
      @options[:alternative]
    end

  end
end
