module Twig
  module Extension
    class Escaper
      include Twig::Extension

      # protected default_strategy;
      # Constructor.
      #
      # @param string|false|callable default_strategy An escaping strategy
      #
      # @see setDefaultStrategy()
      def initialize(default_strategy = 'html')
        set_default_strategy(default_strategy)
      end

      def get_token_parsers
        [Twig::TokenParser::AutoEscape.new]
      end

      def get_node_visitors
        [Twig::NodeVisitor::Escaper.new]
      end

      def get_filters
        [
          Twig::SimpleFilter.new('raw', 'twig_raw_filter', { is_safe: ['all']})
        ]
      end

      # Sets the default strategy to use when not defined by the user.
      #
      # The strategy can be a valid PHP callback that takes the template
      # "filename" as an argument and returns the strategy to use.
      #
      # @param string|false|callable default_strategy An escaping strategy
      def set_default_strategy(default_strategy)
        if default_strategy == 'filename'
          default_strategy = ['Twig::FileExtensionEscapingStrategy', 'guess']
        end
        @default_strategy = default_strategy
      end

      # Gets the default strategy to use when not defined by the user.
      #
      # @param string $filename The template "filename"
      #
      # @return string|false The default strategy to use for the template
      #
      def get_default_strategy(filename)
        # disable string callables to avoid calling a function named html or js,
        # or any other upcoming escaping strategy
        if (!is_string(@default_strategy) && false != @default_strategy)
          return call_user_func(@default_strategy, filename)
        end
        @default_strategy
      end

      def get_name
        'escaper'
      end
    end

    # * Marks a variable as being safe.
    # *
    # * @param string $string A PHP variable
    # *
    # * @return string
    # */
    # def twig_raw_filter(string)
    #   string
    # end
  end
end
