module Twig
  class TokenParserBroker
    # Constructor.
    #
    # @param parsers Array|Traversable A Traversable of Twig::TokenParser instances
    # @param brokers Array|Traversable A Traversable of Twig::TokenParserBroker instances
    # @param trigger_deprecation_error [Boolean]
    def initialize(parsers = [], brokers = [], trigger_deprecation_error = true)
      # if (trigger_deprecation_error)
      #   #  @trigger_error('The '.__CLASS__.' class is deprecated since version 1.12 and will be removed in 2.0.', E_USER_DEPRECATED);
      # end

      @parsers = {}
      parsers.each do |parser|
        @parsers[parser.tag] = parser
      end

      @brokers = []
      brokers.each do |broker|
        @brokers << broker
      end
    end

    # Adds a TokenParser.
    #
    # @param parser A Twig::TokenParser instance
    def add_token_parser(parser)
      @parsers[parser.tag] = parser
    end

    # Removes a TokenParser.
    #
    # @param parser A Twig::TokenParser instance
    def remove_token_parser(parser)
      name = parser.tag
      if @parsers.key?[name] && parser == @parsers[name]
        @parsers.delete(name)
      end
    end

    # Adds a TokenParserBroker.
    #
    # @param broker A Twig::TokenParserBroker instance
    def add_token_parser_broker(broker)
      @brokers << broker
    end

    # Removes a TokenParserBroker.
    #
    # @param broker A Twig::TokenParserBroker instance
    def remove_token_parser_broker(broker)
      if (false != pos = array_search(broker, @brokers))
        @brokers.delete(pos)
      end
    end

    # Gets a suitable TokenParser for a tag.
    #
    # First looks in parsers, then in brokers.
    #
    # @param string tag A tag name
    #
    # @return nil|Twig::TokenParser A Twig::TokenParser or null if no suitable TokenParser was found
    def get_token_parser(tag)
      if @parsers.key?(tag)
        return @parsers[tag]
      end
      broker = @brokers.last
      while broker
        parser = broker.get_token_parser(tag)
        return parser unless parser.nil?
        broker = prev(@brokers)
      end
    end

    def get_parsers
      @parsers
    end

    def parser
      @parser
    end

    def parser=(parser)
      @parser = parser
      @parsers.each do |tag, token_parser|
        token_parser.parser = parser
      end
      @brokers.each do |broker|
        broker.parser = parser
      end
    end
  end
end
