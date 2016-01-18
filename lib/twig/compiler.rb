module Twig

  # Compiles a node.
  class Compiler

    attr_reader :filename, :source

    # Constructor.
    #
    # @param Twig::Environment env The twig environment instance
    def initialize(env)
      @env = env
    end

    # Returns the environment instance related to this compiler.
    #
    # @return Twig::Environment The environment instance
    def environment
      @env
    end

    # Gets the current PHP code after compilation.
    #
    # @return string The PHP code
    def get_source
      @source
    end

    # Compiles a node.
    #
    # @param node Twig::Node    The node to compile
    # @param int                indentation The current indentation
    #
    # @return Twig::Compiler The current compiler instance
    def compile(node, indentation = 0)
      @last_line = nil
      @source = ''
      @debug_info = {}
      @source_offset = 0
      # source code starts at 1 (as we then increment it when we encounter new lines)
      @source_line = 1
      @indentation = indentation

      if node.is_a?(Twig::Node::Module)
        @filename = node.get_attribute('filename')
      end

      node.compile(self)
      self
    end

    def subcompile(node, raw = true)
      unless raw
        add_indentation
      end

      node.compile(self)

      self
    end

    # Adds a raw string to the compiled code.
    #
    # @param string $string The string
    #
    # @return Twig::Compiler The current compiler instance
    def raw(string)
      @source << string
      self
    end

    # Writes a string to the compiled code by adding indentation.
    #
    # @return Twig::Compiler The current compiler instance
    def write *strings
      strings.each do |string|
        add_indentation
        @source << string
      end

      self
    end

    # Appends an indentation to the current PHP code after compilation.
    #
    # @return Twig::Compiler The current compiler instance
    def add_indentation
      @source << (' ' * (@indentation * 2))
      self
    end

    # Adds a quoted string to the compiled code.
    #
    # @param string value The string
    #
    # @return Twig::Compiler The current compiler instance
    def string(value)
      @source << value.inspect
      self
    end

    # Returns a PHP representation of a given value.
    #
    # @param mixed value The value to convert
    #
    # @return Twig::Compiler The current compiler instance
    def repr(value)
      if value.is_a?(Numeric)
        # if (locale = setlocale(LC_NUMERIC, 0))
        #   setlocale(LC_NUMERIC, 'C')
        # end

        raw(value.to_s)

        # unless locale
        #   setlocale(LC_NUMERIC, locale)
        # end
      elsif value.nil?
        raw('nil')
      elsif value.is_a?(TrueClass)
        raw('true')
      elsif value.is_a?(FalseClass)
        raw('false')
      elsif value.is_a?(::Array)
        raw('[')
        first = true
        value.each do |key, v|
          unless first
            raw(',')
          end
          first = false
          repr(key)
          raw(' => ')
          repr(v)
        end
        raw(']')
      elsif value.is_a?(Symbol)
        raw(':').raw(value.to_s)
      else
        string(value)
      end

      self
    end

    # Adds debugging information.
    #
    # @param Twig::Node node The related twig node
    #
    # @return Twig::Compiler The current compiler instance
    def add_debug_info(node)
      if node.lineno != @last_line
        write("# line #{node.lineno}\n")

        @source_line += @source[0..@source_offset].count("\n")
        @source_offset = @source.length
        @debug_info[@source_line] = node.lineno

        @last_line = node.lineno
      end

      self
    end

    def get_debug_info
      # ksort(@debug_info)
      @debug_info
    end

    # Indents the generated code.
    #
    # @param int step The number of indentation to add
    #
    # @return Twig::Compiler The current compiler instance
    def indent(step = 1)
      @indentation += step

      self
    end

    # Outdents the generated code.
    #
    # @param int step The number of indentation to remove
    #
    # @return Twig::Compiler The current compiler instance
    #
    # raise LogicException When trying to outdent too much so the indentation would become negative
    def outdent(step = 1)
      # can't outdent by more steps than the current indentation level
      if (@indentation < step)
        raise LogicException.new('Unable to call outdent() as the indentation would become negative')
      end

      @indentation = @indentation - step

      self
    end

    def get_var_name
      # sprintf('__internal_%s', hash('sha256', uniqid(mt_rand(), true), false))
      "__internal_????"
    end
  end
end
