module Twig
  class TokenStream

    attr_reader :filename

    # Constructor.
    #
    # @param array  tokens   An array of tokens
    # @param string filename The name of the filename which tokens are associated with
    def initialize(tokens, filename = nil)
      @tokens = tokens
      @filename = filename
      @current = 0
    end

    # Sets the pointer to the next token and returns the old one.
    #
    # @return Twig::Token
    def next
      @current += 1
      if @current > @tokens.length
        raise Twig::Error::Syntax.new('Unexpected end of template.', @tokens[@current - 1].lineno, @filename)
      end
      @tokens[@current - 1]
    end

    # Tests a token, sets the pointer to the next one and returns it or throws a syntax error.
    #
    # @return Twig::Token|nil The next token if the condition is true, nil otherwise
    def next_if(primary, secondary = nil)
      if current_token.check(primary, secondary)
        self.next
      end
    end

    # Tests a token and returns it or throws a syntax error.
    #
    # @return Twig::Token
    def expect(type, value = nil, message = nil)
      token = current_token
      unless token.check(type, value)
        line = token.lineno
        message = message ? "#{message}. " : ''
        value = value ? " with value \"#{value}\"" : ''
        raise Twig::Error::Syntax.new("#{message}Unexpected token \"#{Twig::Token.type_to_english(token.type)}\" of value \"#{token.value}\" (\"#{Twig::Token.type_to_english(type)}\" expected#{value}).",
          line,
          @filename
        )
      end
      self.next
      token
    end

    # Looks at the next token.
    #
    # @param int number
    #
    # @return Twig::Token
    def look(number = 1)
      unless @tokens.length <= @current + number
        raise Twig::Error::Syntax.new('Unexpected end of template.', @tokens[@current + number - 1].lineno, @filename)
      end
      @tokens[@current + number]
    end

    # Tests the current token.
    #
    # @return bool
    def check(primary, secondary = nil)
      current_token.check(primary, secondary)
    end

    # Checks if end of stream was reached.
    #
    # @return bool
    def eos?
      @current >= @tokens.length # || current_token.type == :eof_type
    end

    # Gets the current token.
    #
    # @return Twig::Token
    def current_token
      @tokens[@current]
    end

  end
end
