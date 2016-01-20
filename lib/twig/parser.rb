require 'securerandom'

module Twig
  class Parser

    # Constructor.
    #
    # @param env [Twig::Environment] A Twig::Environment instance
    def initialize(env)
      @env = env
      @stack = []
      #  protected $stream;
      #  protected $parent;
      #  protected $handlers;
      #  protected $visitors;
      #  protected $expressionParser;
      #  protected $blocks;
      #  protected $blockStack;
      @macros = {}
      #  protected $env;
      #  protected $reservedMacroNames;
      #  protected $importedSymbols;
      #  protected $traits;
      #  protected $embeddedTemplates = [];
    end

    def environment
      @env
    end

    def get_var_name
      "__internal_#{SecureRandom.uuid.hash}" #TODO! check this!
    end

    def filename
      @stream.filename
    end

    def parse(stream, _test = nil, drop_needle = false)
      # push all variables into the stack to keep the current state of the parser
      # TODO! check this!
      vars = {
        env: @env,
        handlers: @hnadlers,
        visitors: @visitors,
        expression_parser: @expression_parser,
        reserved_macro_names: @reserved_macro_names
      }
      @stack << vars

      # tag handlers
      if @handlers.nil?
        @handlers = @env.get_token_parsers
        @handlers.parser = self
      end

      # node visitors
      @visitors ||= @env.get_node_visitors
      @expression_parser ||= Twig::ExpressionParser.new(self, @env.get_unary_operators, @env.get_binary_operators)
      @stream = stream
      @parent = nil
      @blocks = {}
      @macros = {}
      @traits = []
      @block_stack = []
      @imported_symbols = [{}]
      @embedded_templates = []

      begin
        body = subparse(_test, drop_needle)
        if !@parent.nil? && !(body = filter_body_nodes(body))
          body = Twig::Node.new
        end
      rescue Twig::Error::Syntax => ex
        if !ex.get_template_file
          ex.set_template_file(filename)
        end
        if !ex.get_template_line
          ex.set_template_line(@stream.current_token.lineno)
        end
        raise
      end

      node = Twig::Node::Module.new(Twig::Node::Body.new([body]), @parent, Twig::Node.new(@blocks), Twig::Node.new(@macros), Twig::Node.new(@traits), @embedded_templates, filename)
      traverser = Twig::NodeTraverser.new(@env, @visitors)
      node = traverser.traverse(node)

      # restore previous stack so previous parse() call can resume working
      @stack.pop.each do |key, val|
        instance_variable_set("@#{key}",val)
      end
      node
    end

    def subparse(_test, drop_needle = false)
      lineno = current_token.lineno
      rv = []

      while !@stream.eos?
        token_type = current_token.type

        case token_type
        when :text_type
          token = @stream.next
          rv << Twig::Node::Text.new(token.value, token.lineno)

        when :var_start_type
          token = @stream.next
          expr = @expression_parser.parse_expression
          @stream.expect(:var_end_type)
          rv << Twig::Node::Print.new(expr, token.lineno)

        when :block_start_type
          @stream.next
          token = current_token
          if token.type != :name_type
            raise Twig::Error::Syntax.new('A block must start with a tag name.', token.lineno, filename)
          end
          if !_test.nil? && _test[0].send(_test[1].to_sym, token)
            if drop_needle
              @stream.next
            end
            if rv.count == 1
              return rv[0]
            end
            return Twig::Node.new(rv, nil, lineno)
          end
          subparser = @handlers.get_token_parser(token.value)
          if subparser.nil?
            if _test.nil?
              ex = Twig::Error::Syntax.new("Unknown \"#{token.value}\" tag.", token.lineno, filename)
              ex.add_suggestions(token.value, @env.get_tags.keys)
            else
              ex = Twig::Error::Syntax.new("Unexpected \"#{token.value()}\" tag", token.lineno, filename)
              if _test.is_a?(::Array) && _test.length > 0 && _test[0].is_a?(Twig::TokenParser)
                ex.append_message(" (expecting closing tag for the \"#{_test[0].tag}\" tag defined near line #{lineno}).")
              end
            end
            raise ex
          end
          @stream.next
          node = subparser.parse(token)
          if !node.nil?
            rv << node
          end
        else
          raise Twig::Error::Syntax.new('Lexer or parser ended up in unsupported state.', 0, filename)
        end
      end
      if rv.count ==  1
        return rv[0]
      end
      Twig::Node.new(rv, nil, lineno)
    end

    def add_handler(name, klass)
      @handlers[name] = klass
    end

    def add_node_visitor(visitor)
      @visitors << visitor
    end

    def get_block_stack
      @block_stack
    end

    def peek_block_stack
      @block_stack[@block_stack.count - 1]
    end

    def pop_block_stack
      @block_stack.pop
    end

    def push_block_stack(name)
      @block_stack << name
    end

    def has_block(name)
      @blocks.key?(name)
    end

    def get_block(name)
      @blocks[name]
    end

    def set_block(name, value)
      @blocks[name] = Twig::Node::Body.new([value], nil, value.lineno)
    end

    def has_macro(name)
      @macros.key?(name)
    end

    def set_macro(name, node)
      if is_reserved_macro_name(name)
        raise Twig::Error::Syntax.new("\"#{name}\" cannot be used as a macro name as it is a reserved keyword.", node.lineno, filename)
      end
      @macros[name] = node
    end

    def is_reserved_macro_name(name)
      name = name.downcase
      if @reserved_macro_names.nil?
        @reserved_macro_names = []
        r = @env.base_template_class.split('::').inject(Object){|a,b| a.const_get(b)}
        r.methods.each do |method|
          @reserved_macro_names << method.to_s
        end
      end
      @reserved_macro_names.include?(name.downcase)
    end

    def add_trait(trait)
      @traits << trait
    end

    def has_traits
      @traits.any?
    end

    # def embedTemplate(template)
    #   template.set_Index(mt_rand())
    #   @embedded_templates << template
    # end

    def add_imported_symbol(type, _alias, name = nil, node = nil)
      (@imported_symbols[0][type] ||= {})[_alias] = {'name' => name, 'node' => node}
    end

    def get_imported_symbol(type, _alias)
      @imported_symbols.each do |functions|
        if functions.key?(type) && functions[type].key?(_alias)
          return functions[type][_alias]
        end
      end
      nil
    end

    def is_main_scope
      @imported_symbols.length == 1
    end

    def push_local_scope
      @imported_symbols.unshift({})
    end

    def pop_local_scope
      @imported_symbols.shift
    end

    # Gets the expression parser.
    #
    # @return Twig_ExpressionParser The expression parser
    def get_expression_parser
      @expression_parser
    end

    def get_parent
      @parent
    end

    def set_parent(parent)
      @parent = parent
    end

    # Gets the token stream.
    #
    # @return Twig_TokenStream The token stream
    def get_stream
      @stream
    end

    # Gets the current token.
    #
    # @return [Twig::Token] The current token
    def current_token
      @stream.current_token
    end

    def filter_body_nodes(node)
      # check that the body does not contain non-empty output nodes
      if (
        (node.is_a?(Twig::Node::Text) && !(node.get_attribute('data') =~ /\A[\s]+\z/)) ||
        (!node.is_a?(Twig::Node::Text) && !node.is_a?(Twig::Node::BlockReference) && node.is_a?(Twig::Node::Output))
      )
        raise Twig::Error::Syntax.new('A template that extends another one cannot have a body.', node.lineno, filename)
      end
      # bypass "set" nodes as they "capture" the output
      if node.is_a?(Twig::Node::Set)
        return node
      end
      if node.is_a?(Twig::Node::Output)
        return
      end
      node.nodes.reject! { |n| !n.nil? && filter_body_nodes(n).nil? }
      node
    end
  end
end
