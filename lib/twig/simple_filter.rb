module Twig
  class SimpleFilter

    attr_accessor :arguments
    attr_reader :name, :callable

    def initialize(name, callable, options = {})
      @name = name;
      @callable = callable;
      default = {
        needs_environment: false,
        needs_context: false,
        is_variadic: false,
        # is_safe: nil, # default
        # is_safe_callback: nil, # default
        # pre_escape: nil, # default
        preserves_safety: nil,
        node_class: Twig::Node::Expression::Filter,
        deprecated: false,
        # alternative: nil # default
      }
      @options = default.merge(options)
      @arguments = []
    end

    def get_name
      @name
    end

    def node_class
      @options[:node_class]
    end

    def needs_environment?
      !!@options[:needs_environment]
    end

    def needs_context?
      !!@options[:needs_context]
    end

    def get_safe(filterArgs)
      if @options[:is_safe]
        return @options[:is_safe]
      end
      if @options[:is_safe_callback]
        #TODO! check this!
        call_user_func(@options[:is_safe_callback], filter_args)
      end
    end

    def get_preserves_safety
      @options[:preserves_safety]
    end

    def get_pre_escape
      @options[:pre_escape]
    end

    def is_variadic
      @options[:is_variadic]
    end

    def deprecated?
      @options[:deprecated]
    end

    def get_alternative
      @options[:alternative]
    end

  end
end
