module Twig

  class ExpressionParser

    def initialize(parser, unary_operators, binary_operators)
      @parser = parser
      @unary_operators = unary_operators
      @binary_operators = binary_operators
    end

    def parse_expression(precedence = 0)
      expr = get_primary
      token = @parser.current_token
      while is_binary(token) && @binary_operators[token.value]['precedence'] >= precedence
        op = @binary_operators[token.value]
        @parser.stream.next
        if op.key?(:callable)
          expr = op[:callable][0].send(op[:callable][1], @parser, expr)
        else
          expr1 = parse_expression(:operator_left == op['associativity'] ? op['precedence'] + 1 : op['precedence'])
          klass = op['class']
          expr = klass.new(expr, expr1, token.lineno)
        end
        token = @parser.current_token
      end
      if (0 == precedence)
        return parse_conditional_expression(expr)
      end
      expr
    end

    def get_primary
      token = @parser.current_token
      if is_unary(token)
        operator = @unary_operators[token.value]
        @parser.stream.next
        expr = parse_expression(operator['precedence'])
        klass = operator['class']
        return parse_postfix_expression(klass.new(expr, token.lineno))
      elsif token.check(:punctuation_type, '('.freeze)
        @parser.stream.next
        expr = parse_expression
        @parser.stream.expect(:punctuation_type, ')'.freeze, 'An opened parenthesis is not properly closed')
        return parse_postfix_expression(expr)
      end
      parse_primary_expression
    end

    def parse_conditional_expression(expr)
      while @parser.stream.next_if(:punctuation_type, '?'.freeze)
        if !@parser.stream.next_if(:punctuation_type, ':'.freeze)
          expr2 = parse_expression
          if @parser.stream.next_if(:punctuation_type, ':'.freeze)
            expr3 = parse_expression
          else
            expr3 = Twig::Node::Expression::Constant.new('', @parser.current_token.lineno)
          end
        else
          expr2 = expr
          expr3 = parse_expression
        end
        expr = Twig::Node::Expression::Conditional.new(expr, expr2, expr3, @parser.current_token.lineno)
      end
      expr
    end

    def is_unary(token)
      token.check(:operator_type) && @unary_operators.key?(token.value)
    end

    def is_binary(token)
      token.check(:operator_type) && @binary_operators.key?(token.value)
    end

    def parse_primary_expression
      token = @parser.current_token
      case token.type
      when :name_type
        @parser.stream.next
        case token.value
        when 'true'.freeze,'TRUE'.freeze
          node = Twig::Node::Expression::Constant.new(true, token.lineno)
        when 'false'.freeze,'FALSE'.freeze
          node = Twig::Node::Expression::Constant.new(false, token.lineno)
        when 'none'.freeze,'NONE'.freeze,'null'.freeze,'NULL'.freeze
          node = Twig::Node::Expression::Constant.new(nil, token.lineno)
        else
          if '('.freeze == @parser.current_token.value
            node = get_function_node(token.value, token.lineno)
          else
            node = Twig::Node::Expression::Name.new(token.value, token.lineno)
          end
        end

      when :number_type
        @parser.stream.next
        node = Twig::Node::Expression::Constant.new(token.value, token.lineno)

      when :string_type,:interpolation_start_type
        node = parse_string_expression

      when :operator_type
        if (match = token.value.match(Twig::Lexer::REGEX_NAME)) && (match[0] == token.value)
          # in this context, string operators are variable names
          @parser.stream.next
          node = Twig::Node::Expression::Name.new(token.value, token.lineno)
        elsif @unary_operators.key?(token.value)
          klass = @unary_operators[token.value]['class']
          ref = new ReflectionClass(klass)
          neg_class = 'Twig::Node::Expression::Unary::Neg'
          pos_class = 'Twig::Node::Expression::Unary::Pos'
          unless [neg_class, pos_class].include?(ref.get_name) || ref.is_subclass_of(neg_class) || ref.is_subclass_of(pos_class)
            raise Twig::Error::Syntax.new("Unexpected unary operator \"#{token.value}\".", token.lineno, @parser.filename)
          end
          @parser.stream.next
          expr = parse_primary_expression
          node = klass.new(expr, token.lineno)
        end
      else
        if token.check(:punctuation_type, '[')
          node = parse_array_expression
        elsif token.check(:punctuation_type, '{')
          node = parse_hash_expression
        else
          raise Twig::Error::Syntax.new("Unexpected token \"#{Twig::Token.type_to_english(token.type)}\" of value \"#{token.value}\".", token.lineno, @parser.filename)
        end
      end
      parse_postfix_expression(node)
    end

    def parse_string_expression
      stream = @parser.stream
      nodes = []
      # a string cannot be followed by another string in a single expression
      next_can_be_tring = true
      while true
        if (next_can_be_tring && token = stream.next_if(:string_type))
          nodes << Twig::Node::Expression::Constant.new(token.value, token.lineno)
          next_can_be_tring = false
        elsif (stream.next_if(:interpolation_start_type))
          nodes << parse_expression
          stream.expect(:interpolation_end_type)
          next_can_be_tring = true
        else
          break
        end
      end
      expr = nodes.shift
      nodes.each do |node|
        expr = Twig::Node::Expression::Binary::Concat.new(expr, node, node.lineno)
      end
      expr
    end

    def parse_array_expression
      stream = @parser.stream
      stream.expect(:punctuation_type, '[', 'An array element was expected')

      nodes = []
      first = true
      while !stream.check(:punctuation_type, ']')
        if !first
          stream.expect(:punctuation_type, ',', 'An array element must be followed by a comma')
          # trailing ,?
          if stream.check(:punctuation_type, ']')
            break
          end
        end
        first = false
        nodes << parse_expression
      end
      stream.expect(:punctuation_type, ']', 'An opened array is not properly closed')
      Twig::Node::Expression::Array.new(nodes, stream.current_token.lineno)
    end

    def parse_hash_expression
      stream = @parser.stream
      stream.expect(:punctuation_type, '{', 'A hash element was expected')
      node = Twig::Node::Expression::Hash.new(nil, stream.current_token.lineno)
      first = true
      while !stream.check(:punctuation_type, '}')
        if !first
          stream.expect(:punctuation_type, ',', 'A hash value must be followed by a comma')
          # trailing ,?
          if (stream.check(:punctuation_type, '}'))
            break
          end
        end
        first = false
        # a hash key can be:
        #
        #  # a number -- 12
        #  # a string -- 'a#  # a name, which is equivalent to a string -- a
        #  # an expression, which must be enclosed in parentheses -- (1 + 2)
        if ((token = stream.next_if(:string_type)) || (token = stream.next_if(:name_type)) || token = stream.next_if(:number_type))
          key = Twig::Node::Expression::Constant.new(token.value, token.lineno)
        elsif stream.check(:punctuation_type, '(')
          key = parse_expression
        else
          current = stream.current_token
          raise Twig::Error::Syntax.new("A hash key must be a quoted string, a number, a name, or an expression enclosed in parentheses (unexpected token \"#{Twig::Token.type_to_english(current.type)}\" of value \"#{current.value}\".", current.lineno, @parser.filename)
        end
        stream.expect(:punctuation_type, ':', 'A hash key must be followed by a colon (:)')
        value = parse_expression
        node.add_element(value, key)
      end
      stream.expect(:punctuation_type, '}', 'An opened hash is not properly closed')
      node
    end

    def parse_postfix_expression(node)
      while true
        token = @parser.current_token
        if token.type == :punctuation_type
          if '.' == token.value || '[' == token.value
            node = parse_subscript_expression(node)
          elsif '|' == token.value
            node = parse_filter_expression(node)
          else
            break
          end
        else
          break
        end
      end
      node
    end

    def get_function_node(name, line)
      case name
      when 'parent'
        parse_arguments
        unless @parser.get_block_stack
          raise Twig::Error::Syntax.new('Calling "parent" outside a block is forbidden.', line, @parser.filename)
        end
        if !@parser.parent && !@parser.has_traits
          raise Twig::Error::Syntax.new('Calling "parent" on a template that does not extend nor "use" another template is forbidden.', line, @parser.filename)
        end
        return Twig::Node::Expression::Parent.new(@parser.peek_block_stack, line)
      when 'block'
        return Twig::Node::Expression::BlockReference.new(parse_arguments.nodes[0], false, line)
      when 'attribute'
        args = parse_arguments
        if args.length < 2
          raise Twig::Error::Syntax.new('The "attribute" function takes at least two arguments (the variable and the attributes).', line, @parser.filename)
        end
        return Twig::Node::Expression::GetAttr.new(args.nodes[0], args.nodes[1], args.length > 2 ? args.get_node(2) : nil, :any_call, line)
      else
        if _alias = @parser.get_imported_symbol('function', name)
          arguments = Twig::Node::Expression::Array.new([], line)
          parse_arguments.each do |n|
            arguments.add_element(n)
          end
          node = Twig::Node::Expression::MethodCall.new(_alias['node'], _alias['name'], arguments, line)
          node.set_attribute(:safe, true)
          return node
        end
        args = parse_arguments(true)
        klass = get_function_node_class(name, line)
        klass.new(name, args, line)
      end
    end

    def parse_subscript_expression(node)
      stream = @parser.stream
      token = stream.next
      lineno = token.lineno
      arguments = Twig::Node::Expression::Array.new([], lineno)
      type = :any_call
      if token.value == '.'
        token = stream.next
        if token.type == :name_type ||
           token.type == :number_type ||
          (token.type == :operator_type && Twig::Lexer::REGEX_NAME =~ token.value)

          arg = Twig::Node::Expression::Constant.new(token.value, lineno)
          if stream.check(:punctuation_type, '(')
            type = :method_call
            parse_arguments.each do |n|
              arguments.add_element(n)
            end
          end
        else
          raise Twig::Error::Syntax.new('Expected name or number', lineno, @parser.filename)
        end
        if node.is_a?(Twig::Node::Expression::Name) && !@parser.get_imported_symbol('template', node.get_attribute('name')).nil?
          unless arg.is_a?(Twig::Node::Expression::Constant)
            raise Twig::Error::Syntax.new("Dynamic macro names are not supported (called on \"#{node.get_attribute('name')}\").", token.lineno, @parser.filename)
          end
          name = arg.get_attribute('value')
          if @parser.is_reserved_macro_name(name)
            raise Twig::Error::Syntax.new("\"#{name}\" cannot be called as macro as it is a reserved keyword.", token.lineno, @parser.filename)
          end
          node = Twig::Node::Expression::MethodCall.new(node, 'get'.name, arguments, lineno)
          node.set_attribute(:safe, true)
          return node
        end
      else
        type = :array_call
        # slice?
        slice = false
        if stream.check(:punctuation_type, ':')
          slice = true
          arg = Twig::Node::Expression::Constant.new(0, token.lineno)
        else
          arg = parse_expression
        end
        if stream.next_if(:punctuation_type, ':')
          slice = true
        end
        if slice
          if stream.check(:punctuation_type, ']')
            length = Twig::Node::Expression::Constant.new(nil, token.lineno)
          else
            length = parse_expression
          end
          klass = get_filter_node_class('slice', token.lineno)
          arguments = Twig::Node.new([arg, length])
          filter = klass.new(node, Twig::Node::Expression::Constant.new('slice', token.lineno), arguments, token.lineno)
          stream.expect(:punctuation_type, ']')
          return filter
        end
        stream.expect(:punctuation_type, ']')
      end
      Twig::Node::Expression::GetAttr.new(node, arg, arguments, type, lineno)
    end

    def parse_filter_expression(node)
      @parser.stream.next
      parse_filter_expression_raw(node)
    end

    def parse_filter_expression_raw(node, tag = nil)
      while true
        token = @parser.stream.expect(:name_type)
        name = Twig::Node::Expression::Constant.new(token.value, token.lineno)
        unless @parser.stream.check(:punctuation_type, '(')
          arguments = Twig::Node.new
        else
          arguments = parse_arguments(true)
        end
        klass = get_filter_node_class(name.get_attribute('value'), token.lineno)
        node = klass.new(node, name, arguments, token.lineno, tag)
        unless @parser.stream.check(:punctuation_type, '|')
          break
        end
        @parser.stream.next
      end
      node
    end

    #  Parses arguments.
    #
    #  @param bool named_arguments Whether to allow named arguments or not
    #  @param bool definition     Whether we are parsing arguments for a function definition
    #
    #  @return [Twig::Node]
    #
    #  @raise [Twig::Error::Syntax]
    def parse_arguments(named_arguments = false, definition = false)
      args = {}
      stream = @parser.stream
      stream.expect(:punctuation_type, '(', 'A list of arguments must begin with an opening parenthesis')
      while !stream.check(:punctuation_type, ')')
        if args.any?
          stream.expect(:punctuation_type, ',', 'Arguments must be separated by a comma')
        end
        if definition
          token = stream.expect(:name_type, nil, 'An argument must be a name')
          value = Twig::Node::Expression::Name.new(token.value, @parser.current_token.lineno)
        else
          value = parse_expression
        end
        name = nil
        if named_arguments && token = stream.next_if(:operator_type, '=')
          unless value.is_a?(Twig::Node::Expression::Name)
            raise Twig::Error::Syntax.new("A parameter name must be a string, \"#{value.class.name}\" given.", token.lineno, @parser.filename)
          end
          name = value.get_attribute('name')
          if definition
            value = parse_primary_expression
            unless check_constant_expression(value)
              raise Twig::Error::Syntax.new("A default value for an argument must be a constant (a boolean, a string, a number, or an array).", token.lineno, @parser.filename)
            end
          else
            value = parse_expression
          end
        end
        if definition
          if name.nil?
            name = value.get_attribute('name')
            value = Twig::Node::Expression::Constant.new(nil, @parser.current_token.lineno)
          end
          args[name] = value
        else
          if name.nil?
            args[args.length] = value
          else
            args[name] = value
          end
        end
      end
      stream.expect(:punctuation_type, ')', 'A list of arguments must be closed by a parenthesis')
      Twig::Node.new(args)
    end

    def parse_assignment_expression
      targets = []
      while true
        token = @parser.stream.expect(:name_type, nil, 'Only variables can be assigned to')
        if ['true', 'false', 'none'].include?(token.value)
          raise Twig::Error::Syntax.new("You cannot assign a value to \"#{token.value}\".", token.lineno, @parser.filename)
        end
        targets << Twig::Node::Expression::AssignName.new(token.value, token.lineno)
        unless @parser.stream.next_if(:punctuation_type, ',')
          break
        end
      end
      Twig::Node.new(targets)
    end

    def parse_multitarget_expression
      targets = [parse_expression]
      while @parser.stream.next_if(:punctuation_type, ',')
        targets << parse_expression
      end
      Twig::Node.new(targets)
    end

    def get_function_node_class(name, line)
      env = @parser.environment
      unless (function = env.get_function(name))
        ex = Twig::Error::Syntax.new("Unknown \"#{name}\" function.", line, @parser.filename)
        ex.add_suggestions(name, env.get_functions.keys)
        raise ex
      end
      if function.is_a?(Twig::SimpleFunction)
        if function.deprecated?
          message = "Twig function \"#{function.name}\" is deprecated"
          if function.get_alternative
            message << ". Use \"#{function.get_alternative}\" instead"
          end
          message << " in \"#{@parser.filename}\" at line #{line}."
          warn message
        end
        return function.node_class
      end
      function.is_a?(Twig::Function::Node) ? function.class : Twig::Node::Expression::Function
    end

    def get_filter_node_class(name, line)
      env = @parser.environment
      unless filter = env.get_filter(name)
        ex = Twig::Error::Syntax.new("Unknown \"#{name}\" filter.", line, @parser.filename)
        ex.add_suggestions(name, env.get_filters.keys)
        raise ex
      end
      if filter.is_a?(Twig::SimpleFilter) && filter.deprecated?
        message = "Twig Filter \"#{filter.name}\" is deprecated"
        if filter.get_alternative
          message << ". Use \"#{filter.get_alternative}\" instead"
        end
        message << " in #{@parser.filename} at line #{line}."
        # @trigger_error(message, E_USER_DEPRECATED)
      end
      if filter.is_a?(Twig::SimpleFilter)
        return filter.node_class
      end
      filter.is_a?(Twig::Filter::Node) ? filter.class : Twig::Node::Expression::Filter
    end

    # checks that the node only contains "constant" elements
    def check_constant_expression(node)
      unless node.is_a?(Twig::Node::Expression::Constant) || node.is_a?(Twig::Node::Expression::Array) || node.is_a?(Twig::Node::Expression::Hash) || node.is_a?(Twig::Node::Expression::Unary::Neg) || node.is_a?(Twig::Node::Expression::Unary::Pos)
        return false
      end
      node.nodes.each do |n|
        unless check_constant_expression(n)
          return false
        end
      end
      true
    end

  end
end
