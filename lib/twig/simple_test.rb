module Twig
  class SimpleTest

    attr_reader :name, :callabke

    def initialize(name, callable, options = {})
      @name = name
      @callable = callable
      @options = {
        is_variadic: false,
        node_class: Twig::Node::Expression::Test,
        deprecated: false,
        alternative: nil
      }.merge(options)
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
