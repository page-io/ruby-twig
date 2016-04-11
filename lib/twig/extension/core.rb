module Twig
  module Extension
    class Core
      include Twig::Extension

      def initialize
        @date_formats = 'F j, Y H:i'
        @date_interval_format = '%d days'

        @number_format = {
          decimal: 0,
          decimal_point: '.',
          thousand_separator: ','
        }
        # @timezone = nil
        @escapers = []
      end

      #  Defines a new escaper to be used via the escape filter.
      #
      #  @param string   strategy The strategy name that should be used as a strategy in the escape call
      #  @param callable $callable A valid PHP callable
      def set_escaper(strategy, callable)
        @escapers[strategy] = callable
      end

      #  Gets all defined escapers.
      #
      #  @return array An array of escapers
      def get_escapers
        @escapers
      end

      #  Sets the default format to be used by the date filter.
      #
      #  @param string format             The default date format string
      #  @param string $dateIntervalFormat The default date interval format string
      def set_date_format(format)
        @date_format = format
      end

      #  Gets the default format to be used by the date filter.
      #
      #  @return array The default date format string and the default date interval format string
      def get_date_format
        @date_format
      end

      #  Sets the default format to be used by the date filter.
      #
      #  @param string format             The default date format string
      #  @param string $dateIntervalFormat The default date interval format string
      def set_date_interval_format(date_interval_format)
        @date_interval_format = date_interval_format
      end

      #  Gets the default format to be used by the date filter.
      #
      #  @return array The default date format string and the default date interval format string
      def get_date_interval_format
        @date_interval_format
      end

      #  Sets the default timezone to be used by the date filter.
      #
      #  @param DateTimeZone|string $timezone The default timezone string or a DateTimeZone object
      def set_timezone(timezone)
        @timezone = timezone #timezone.is_a?(DateTimeZone ? $timezone : new DateTimeZone($timezone);
      end

      #  Gets the default timezone to be used by the date filter.
      #
      #  @return DateTimeZone The default timezone currently in use
      def get_timezone
        @timezone ||= Time.now.getlocal.zone
      end

      #  Sets the default format to be used by the number_format filter.
      #
      #  @param int    $decimal      The number of decimal places to use.
      #  @param string $decimalPoint The character(s) to use for the decimal point.
      #  @param string $thousandSep  The character(s) to use for the thousands separator.
      # def setNumberFormat($decimal, $decimalPoint, $thousandSep)
      #     $this->numberFormat = array($decimal, $decimalPoint, $thousandSep);
      # end

      #  Get the default format used by the number_format filter.
      #
      #  @return The arguments for number_format
      def get_number_format
        @number_format
      end

      def get_token_parsers
        [
          Twig::TokenParser::For.new,
          Twig::TokenParser::If.new,
          Twig::TokenParser::Extends.new,
          Twig::TokenParser::Include.new,
          Twig::TokenParser::Block.new,
          Twig::TokenParser::Use.new,
          Twig::TokenParser::Filter.new,
          Twig::TokenParser::Macro.new,
          Twig::TokenParser::Import.new,
          Twig::TokenParser::From.new,
          Twig::TokenParser::Set.new,
          Twig::TokenParser::Spaceless.new,
          Twig::TokenParser::Flush.new,
          Twig::TokenParser::Do.new,
          Twig::TokenParser::Embed.new,
        ]
      end

      def get_filters
        [
          # formatting filters
          Twig::SimpleFilter.new('date', 'Twig::Runtime.twig_date_format_filter', {needs_environment: true}),
          Twig::SimpleFilter.new('date_modify', 'Twig::Runtime.twig_date_modify_filter', {needs_environment: true}),
          Twig::SimpleFilter.new('format', 'twig_format'),
          Twig::SimpleFilter.new('replace', 'Twig::Runtime.twig_replace_filter'),
          Twig::SimpleFilter.new('number_format', 'Twig::Runtime.twig_number_format_filter', {needs_environment: true}),
          Twig::SimpleFilter.new('abs', 'Twig::Runtime.twig_abs'),
          Twig::SimpleFilter.new('round', 'Twig::Runtime.twig_round'),
          # encoding
          Twig::SimpleFilter.new('url_encode', 'Twig::Runtime.twig_urlencode_filter'),
          Twig::SimpleFilter.new('json_encode', 'Twig::Runtime.twig_jsonencode_filter'),
          Twig::SimpleFilter.new('convert_encoding', 'twig_convert_encoding'),
          # string filters
          Twig::SimpleFilter.new('title', 'Twig::Runtime.twig_title_string_filter'),
          Twig::SimpleFilter.new('capitalize', 'Twig::Runtime.twig_capitalize_string_filter', {needs_environment: true}),
          Twig::SimpleFilter.new('upper', 'Twig::Runtime.twig_upper_filter'),
          Twig::SimpleFilter.new('lower', 'Twig::Runtime.twig_lower_filter'),
          Twig::SimpleFilter.new('striptags', 'twig_striptags'),
          Twig::SimpleFilter.new('trim', 'Twig::Runtime.twig_trim'),
          Twig::SimpleFilter.new('nl2br', 'twig_nl2br', {pre_escape: 'html', is_safe: ['html']}),
          # array helpers
          Twig::SimpleFilter.new('join', 'Twig::Runtime.twig_join_filter'),
          Twig::SimpleFilter.new('split', 'Twig::Runtime.twig_split_filter', {needs_environment: true}),
          Twig::SimpleFilter.new('sort', 'Twig::Runtime.twig_sort_filter'),
          Twig::SimpleFilter.new('merge', 'Twig::Runtime.twig_array_merge'),
          Twig::SimpleFilter.new('batch', 'Twig::Runtime.twig_array_batch'),
          # string/array filters
          Twig::SimpleFilter.new('reverse', 'Twig::Runtime.twig_reverse_filter', {needs_environment: true}),
          Twig::SimpleFilter.new('length', 'Twig::Runtime.twig_length_filter', {needs_environment: true}),
          Twig::SimpleFilter.new('slice', 'Twig::Runtime.twig_slice', {needs_environment: true}),
          Twig::SimpleFilter.new('first', 'Twig::Runtime.twig_first', {needs_environment: true}),
          Twig::SimpleFilter.new('last', 'Twig::Runtime.twig_last', {needs_environment: true}),
          # iteration and runtime
          Twig::SimpleFilter.new('default', 'Twig::Runtime.twig_default_filter'),
          Twig::SimpleFilter.new('keys', 'Twig::Runtime.twig_get_array_keys_filter'),
          # escaping
          Twig::SimpleFilter.new('escape', 'Twig::Runtime.twig_escape_filter', {needs_environment: true, is_safe_callback: 'twig_escape_filter_is_safe'}),
          Twig::SimpleFilter.new('e', 'Twig::Runtime.twig_escape_filter', {needs_environment: true, is_safe_callback: 'twig_escape_filter_is_safe'}),
        ]
      end

      def get_functions
        [
          Twig::SimpleFunction.new('max', 'twig_max'),
          Twig::SimpleFunction.new('min', 'twig_min'),
          Twig::SimpleFunction.new('range', 'Twig::Runtime.twig_range'),
          Twig::SimpleFunction.new('constant', 'Twig::Runtime.twig_constant'),
          Twig::SimpleFunction.new('cycle', 'Twig::Runtime.twig_cycle'),
          Twig::SimpleFunction.new('random', 'Twig::Runtime.twig_random', {needs_environment: true}),
          Twig::SimpleFunction.new('date', 'Twig::Runtime.twig_date_converter', {needs_environment: true}),
          Twig::SimpleFunction.new('include', 'Twig::Runtime.twig_include', {needs_environment: true, needs_context: true, is_safe: ['all']}),
          Twig::SimpleFunction.new('source', 'Twig::Runtime.twig_source', {needs_environment: true, is_safe: ['all']}),
        ]
      end

      def get_tests
        [
          Twig::SimpleTest.new('even', nil, { node_class: Twig::Node::Expression::Test::Even}),
          Twig::SimpleTest.new('odd', nil, { node_class: Twig::Node::Expression::Test::Odd}),
          Twig::SimpleTest.new('defined', nil, { node_class: Twig::Node::Expression::Test::Defined}),
          Twig::SimpleTest.new('sameas', nil, { node_class: Twig::Node::Expression::Test::Sameas, deprecated: true, alternative: 'same as'}),
          Twig::SimpleTest.new('same as', nil, { node_class: Twig::Node::Expression::Test::Sameas}),
          Twig::SimpleTest.new('none', nil, { node_class: Twig::Node::Expression::Test::Null}),
          Twig::SimpleTest.new('null', nil, { node_class: Twig::Node::Expression::Test::Null}),
          Twig::SimpleTest.new('divisibleby', nil, { node_class: Twig::Node::Expression::Test::Divisibleby, deprecated: true, alternative: 'divisible by'}),
          Twig::SimpleTest.new('divisible by', nil, { node_class: Twig::Node::Expression::Test::Divisibleby}),
          Twig::SimpleTest.new('constant', nil, { node_class: Twig::Node::Expression::Test::Constant}),
          Twig::SimpleTest.new('empty', 'Twig::Runtime.twig_test_empty'),
          Twig::SimpleTest.new('iterable', 'Twig::Runtime.twig_test_iterable'),
        ]
      end

      def get_operators
        [
          {
            'not' => {'precedence' => 50, 'class' => Twig::Node::Expression::Unary::Not},
            '-' => {'precedence' => 500, 'class' => Twig::Node::Expression::Unary::Neg},
            '+' => {'precedence' => 500, 'class' => Twig::Node::Expression::Unary::Pos},
          },
          {
            'or' => {'precedence' => 10, 'class' => Twig::Node::Expression::Binary::Or, 'associativity' => :operator_left},
            'and' => {'precedence' => 15, 'class' => Twig::Node::Expression::Binary::And, 'associativity' => :operator_left},
            'b-or' => {'precedence' => 16, 'class' => Twig::Node::Expression::Binary::BitwiseOr, 'associativity' => :operator_left},
            'b-xor' => {'precedence' => 17, 'class' => Twig::Node::Expression::Binary::BitwiseXor, 'associativity' => :operator_left},
            'b-and' => {'precedence' => 18, 'class' => Twig::Node::Expression::Binary::BitwiseAnd, 'associativity' => :operator_left},
            '==' => {'precedence' => 20, 'class' => Twig::Node::Expression::Binary::Equal, 'associativity' => :operator_left},
            '!=' => {'precedence' => 20, 'class' => Twig::Node::Expression::Binary::NotEqual, 'associativity' => :operator_left},
            '<' => {'precedence' => 20, 'class' => Twig::Node::Expression::Binary::Less, 'associativity' => :operator_left},
            '>' => {'precedence' => 20, 'class' => Twig::Node::Expression::Binary::Greater, 'associativity' => :operator_left},
            '>=' => {'precedence' => 20, 'class' => Twig::Node::Expression::Binary::GreaterEqual, 'associativity' => :operator_left},
            '<=' => {'precedence' => 20, 'class' => Twig::Node::Expression::Binary::LessEqual, 'associativity' => :operator_left},
            'not in' => {'precedence' => 20, 'class' => Twig::Node::Expression::Binary::NotIn, 'associativity' => :operator_left},
            'in' => {'precedence' => 20, 'class' => Twig::Node::Expression::Binary::In, 'associativity' => :operator_left},
            'matches' => {'precedence' => 20, 'class' => Twig::Node::Expression::Binary::Matches, 'associativity' => :operator_left},
            'starts with' => {'precedence' => 20, 'class' => Twig::Node::Expression::Binary::StartsWith, 'associativity' => :operator_left},
            'ends with' => {'precedence' => 20, 'class' => Twig::Node::Expression::Binary::EndsWith, 'associativity' => :operator_left},
            '..' => {'precedence' => 25, 'class' => Twig::Node::Expression::Binary::Range, 'associativity' => :operator_left},
            '+' => {'precedence' => 30, 'class' => Twig::Node::Expression::Binary::Add, 'associativity' => :operator_left},
            '-' => {'precedence' => 30, 'class' => Twig::Node::Expression::Binary::Sub, 'associativity' => :operator_left},
            '~' => {'precedence' => 40, 'class' => Twig::Node::Expression::Binary::Concat, 'associativity' => :operator_left},
            '*' => {'precedence' => 60, 'class' => Twig::Node::Expression::Binary::Mul, 'associativity' => :operator_left},
            '/' => {'precedence' => 60, 'class' => Twig::Node::Expression::Binary::Div, 'associativity' => :operator_left},
            '//' => {'precedence' => 60, 'class' => Twig::Node::Expression::Binary::FloorDiv, 'associativity' => :operator_left},
            '%' => {'precedence' => 60, 'class' => Twig::Node::Expression::Binary::Mod, 'associativity' => :operator_left},
            'is' => {'precedence' => 100, :callable => [self, 'parse_test_expression'], 'associativity' => :operator_left},
            'is not' => {'precedence' => 100, :callable => [self, 'parse_not_test_expression'], 'associativity' => :operator_left},
            '**' => {'precedence' => 200, 'class' => Twig::Node::Expression::Binary::Power, 'associativity' => :operator_right},
          }
        ]
      end

      def parse_not_test_expression(parser, node)
        Twig::Node::Expression::Unary::Not.new(parse_test_expression(parser, node), parser.current_token.lineno)
      end

      def parse_test_expression(parser, node)
        stream = parser.stream
        name, test = get_test(parser, node.lineno)
        if test.is_a?(Twig::SimpleTest) && test.deprecated?
          message = "Twig Test \"#{name}\" is deprecated"
          if test.get_alternative
            message.concat ". Use \"#{test.get_alternative}\" instead"
          end
          message.concat " in #{stream.filename} at line #{stream.current_token.lineno}."
          # @trigger_error(message, E_USER_DEPRECATED)
        end
        klass = get_test_node_class(parser, test)
        arguments = nil
        if stream.check(:punctuation_type, '(')
          arguments = parser.expression_parser.parse_arguments(true)
        end
        klass.new(node, name, arguments, parser.current_token.lineno)
      end

      def get_test(parser, line)
        stream = parser.stream
        name = stream.expect(:name_type).value
        env = parser.environment
        if test = env.get_test(name)
          return [name, test]
        end
        if stream.check(:name_type)
          # try 2-words tests
          name.concat = ' ', parser.current_token.value
          if test = env.get_test(name)
            parser.stream.next
            return [name, test]
          end
        end
        ex = Twig::Error::Syntax.new("Unknown \"#{name}\" test.", line, parser.filename)
        ex.add_suggestions(name, env.get_tests.keys)
        raise ex
      end

      def get_test_node_class(parser, _test)
        if _test.is_a?(Twig::SimpleTest)
          return _test.node_class
        end
        _test.is_a?(Twig::Test::Node) ? _test.class : Twig::Node::Expression::Test
      end

      def get_name
        'core'
      end
    end
  end
end
