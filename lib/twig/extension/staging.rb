module Twig
  module Extension
    class Staging
      include Twig::Extension

      def initialize
        @functions = {}
        @filters = {}
        @visitors = []
        @token_parsers = []
        @globals = {}
        @tests = {}
      end

      def add_function(name, function)
        @functions[name] = function
      end

      def get_functions
        @functions.values
      end

      def add_filter(name, filter)
        @filters[name] = filter
      end

      def get_filters
        @filters.values
      end

      def add_node_visitor(visitor)
        @visitors << visitor
      end

      def get_node_visitors
        @visitors
      end

      def add_token_parser(parser)
        @token_parsers << parser
      end

      def get_token_parsers
        @token_parsers
      end

      def add_global(name, value)
        @globals[name] = value
      end

      def get_globals
        @globals
      end

      def add_test(name, test)
        raise ArgumentError.new('name can\'t be nil') if name.nil?
        @tests[name] = test
      end

      def get_tests
        @tests.values
      end

      def get_name
        'staging'.freeze
      end
    end
  end
end
