require 'strscan'
module Twig

  class Lexer
    REGEX_NAME = /[a-zA-Z_\u007f-\u00ff][a-zA-Z0-9_\u007f-\u00ff]*/
    REGEX_NUMBER = /[0-9]+(\.[0-9]+)?/
    REGEX_STRING = /"([^#"\\]*(?:\\.[^#"\\]*)*)"|\'([^\'\\]*(?:\\.[^\'\\]*)*)\'/m
    REGEX_DQ_STRING_DELIM = /"/
    REGEX_DQ_STRING_PART = /[^#"\\]*(?:(?:\\.|#(?!\{))[^#"\\]*)*/m
    PUNCTUATION = '()[]{}?:.,|'

    def initialize(env, options = {})

      @env = env
      @options = {
        :tag_comment => ['{#', '#}'],
        :tag_block => ['{%', '%}'],
        :tag_variable => ['{{', '}}'],
        :whitespace_trim => '-',
        :interpolation => ['#{', '}'],
      }.merge(options)

      @regexes = {
        :lex_var => /\s*#{Regexp.escape(@options[:whitespace_trim])}#{Regexp.escape(@options[:tag_variable][1])}\s*|\s*#{Regexp.escape(@options[:tag_variable][1])}/,
        :lex_end_block => /\s*(?:#{Regexp.escape(@options[:whitespace_trim])}#{Regexp.escape(@options[:tag_block][1])}\s*|\s*#{Regexp.escape(@options[:tag_block][1])})\n?/,
        :lex_raw_data => /(#{Regexp.escape(@options[:tag_block][0])}#{Regexp.escape(@options[:whitespace_trim])}|#{Regexp.escape(@options[:tag_block][0])})\s*(?:endverbatim)\s*(?:#{Regexp.escape(@options[:whitespace_trim])}#{Regexp.escape(@options[:tag_block][1])}\s*|\s*#{Regexp.escape(@options[:tag_block][1])})/m,
        :operator => get_operator_regex,
        :lex_end_comment => /(?:#{Regexp.escape(@options[:whitespace_trim])}#{Regexp.escape(@options[:tag_comment][1])}\s*|#{Regexp.escape(@options[:tag_comment][1])})\n?/m,
        :lex_block_raw => /\s*(raw|verbatim)\s*(?:#{Regexp.escape(@options[:whitespace_trim])}#{Regexp.escape(@options[:tag_block][1])}\s*|\s*#{Regexp.escape(@options[:tag_block][1])})/m,
        :lex_block_line => /\s*line\s+(\d+)\s*#{Regexp.escape(@options[:tag_block][1])}/m,
        :lex_tokens_start => /(.*?)(#{Regexp.escape(@options[:tag_variable][0])}|#{Regexp.escape(@options[:tag_block][0])}|#{Regexp.escape(@options[:tag_comment][0])})(#{Regexp.escape(@options[:whitespace_trim])})?/m,
        :interpolation_start => /#{Regexp.escape(@options[:interpolation][0])}\s*/,
        :interpolation_end => /\s*#{Regexp.escape(@options[:interpolation][1])}/
      }
    end

    def tokenize(code, filename = nil)
      @code = code.gsub(/\r\n?/, "\n")
      @filename = filename

      @tokens = []
      @state = :state_data
      @states = []
      @brackets = []

      @ss = StringScanner.new(@code)
      initialize_line_position

      until @ss.eos?
        case @state
        when :state_data
          lex_data
        when :state_block
          lex_block
        when :state_var
          lex_var
        when :state_string
          lex_string
        when :state_interpolation
          lex_interpolation
        end
      end

      push_token(:eof_type)
      if @brackets.any?
        expect, lineno = @brackets.pop
        raise Twig::Error::Syntax.new("Unclosed \"#{expect}\".", lineno, @filename)
      end

      Twig::TokenStream.new(@tokens, @filename)
    end

    def lex_data
      @ss.scan(@regexes[:lex_tokens_start])

      # if no matches are left we return the rest of the template as simple text token
      if @ss.matched.nil?
        push_token(:text_type, @ss.rest)
        @ss.terminate
        return
      end

      text = @ss[1]
      if (@ss[3] == @options[:whitespace_trim])
        text.rstrip!
      end
      push_token(:text_type, text)

      case @ss[2]
      when @options[:tag_comment][0]
        lex_comment
      when @options[:tag_block][0]
        # raw data?
        if @ss.scan(@regexes[:lex_block_raw])
          lex_raw_data(@ss[1])

        # {% line \d+ %}
        elsif @ss.scan(@regexes[:lex_block_line])
          initialize_line_position(@ss[1].to_i)

        else
          push_token(:block_start_type)
          push_state(:state_block)
          @current_var_block_line = calculate_lineno
        end
      when @options[:tag_variable][0]
        push_token(:var_start_type)
        push_state(:state_var)
        @current_var_block_line = calculate_lineno
      end
    end

    def lex_block
      if (@brackets.empty? && @ss.scan(@regexes[:lex_end_block]))
        push_token(:block_end_type)
        pop_state
      else
        lex_expression
      end
    end

    def lex_var
      if @brackets.empty? && @ss.scan(@regexes[:lex_var])
        push_token(:var_end_type)
        pop_state
      else
        lex_expression
      end
    end

    def lex_expression
      # whitespace
      if @ss.scan(/\s+/)
        if @ss.eos?
          raise Twig::Error::Syntax.new("Unclosed #{@state == :state_block ? 'block' : 'variable'}.", @current_var_block_line, @filename)
        end
      end
      # operators
      if @ss.scan(@regexes[:operator])
        push_token(:operator_type, @ss.matched.gsub(/\s+/, ' '))

      # names
      elsif @ss.scan(REGEX_NAME)
        push_token(:name_type, @ss.matched)

      # numbers
      elsif @ss.scan(REGEX_NUMBER)
        if @ss[1]
          number = @ss.matched.to_f  # floats
        else
          number = @ss.matched.to_i  # integer
        end
        push_token(:number_type, number)

      # punctuation
      elsif PUNCTUATION.include?(@ss.peek(1))
        char = @ss.getch

        # opening bracket
        if '([{'.include?(char)
          @brackets << [char, calculate_lineno]

        # closing bracket
        elsif ')]}'.include?(char)
          if @brackets.empty?
            lineno = calculate_lineno
            raise Twig::Error::Syntax.new("Unexpected '#{char}'. line: #{lineno}, filename: #{@filename}")
          end
          expect, lineno = @brackets.pop
          if ('([{'[')]}'.index(char)] != expect)
            raise Twig::Error::Syntax.new("Unclosed '#{expect}'. line: #{lineno}, filename: #{@filename}")
          end
        end
        push_token(:punctuation_type, char);

      # strings
      elsif @ss.scan(REGEX_STRING)
        push_token(:string_type, (@ss[1]||@ss[2]).gsub( /\\(.)/,'\1'))

      # opening double quoted string
      elsif @ss.scan(REGEX_DQ_STRING_DELIM)
        @brackets << ['"', calculate_lineno]
        push_state(:state_string)

      # unlexable
      else
        raise Twig::Error::Syntax.new("Unexpected character '#{@ss.peek(1)}'", calculate_lineno, @filename)
      end
    end

    def lex_raw_data(tag)
      if 'raw' == tag
        raise Twig::Error::Syntax.new('Twig Tag "raw" is deprecated. Use "verbatim" instead.', calculate_lineno, @filename)
      end
      unless @ss.scan_until(@regexes[:lex_raw_data])
        raise Twig::Error::Syntax.new("Unexpected end of file: Unclosed \"#{tag}\" block.", calculate_lineno, @filename)
      end

      text = @ss[1]
      if (@ss[3] == @options[:whitespace_trim])
        text.rstrip!
      end

      push_token(:text_type, text)
    end

    def lex_comment
      unless @ss.scan_until(@regexes[:lex_end_comment])
        raise Twig::Error::Syntax.new('Unclosed comment.', calculate_lineno, @filename)
      end
    end

    def lex_string
      if @ss.scan(@regexes[:interpolation_start])
        @brackets << [@options[:interpolation][0], calculate_lineno]
        push_token(:interpolation_start_type)
        push_state(:state_interpolation)
      elsif @ss.scan(REGEX_DQ_STRING_PART) && @ss.matched.length > 0
        push_token(:string_type, @ss.matched)
      elsif @ss.scan(REGEX_DQ_STRING_DELIM)
        expect, lineno = @brackets.pop
        if @ss.matched != '"'
          raise Twig::Error::Syntax.new("Unclosed #{expect}.", lineno, @filename)
        end
        pop_state
      else
        raise 'Invalid state'
      end
    end

    def lex_interpolation
      bracket = @brackets.last
      if @options[:interpolation][0] == bracket[0] && @ss.scan(@regexes[:interpolation_end])
        @brackets.pop
        push_token(:interpolation_end_type)
        pop_state
      else
        lex_expression
      end
    end

    protected

      def push_token(type, value = nil)
        # do not push empty text tokens
        if (type == :text_type && '' == value)
          return
        end
        @tokens << Twig::Token.new(type, value, calculate_lineno)
      end

      def get_operator_regex
        operators = ['='] + @env.get_unary_operators.keys + @env.get_binary_operators.keys
        operators.sort!.reverse!

        regexp = operators.map do |operator|
          r = Regexp.escape(operator).gsub(/\\ /,' ')
          # an operator that ends with a character must be followed by
          # a whitespace or a parenthesis
          if operator =~ /[A-Za-z]\z/
            r += '(?=[\\s()])'
          end
          # an operator with a space can be any amount of whitespaces
          r.gsub(/\s+/, '\s+')
        end
        /#{regexp.join('|')}/
      end

      def push_state(state)
        @states << @state
        @state = state
      end

      def pop_state
        if @states.empty?
          raise 'Cannot pop state without a previous state'
        end
        @state = @states.pop
      end

      def initialize_line_position(lineno=1)
        @lineno = lineno
        @line_start = @ss.pos
      end

      def calculate_lineno
        # TODO! check this, the line is calculated from the position at the end of the expression
        if @line_start < @ss.pos
          @lineno += @code[@line_start..@ss.pos-1].count("\n")
          @line_start = @ss.pos
        elsif @line_start > @ss.pos
          raise "can't go back"
        end
        @lineno
      end
  end
end
