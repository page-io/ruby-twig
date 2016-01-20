module Twig
  class TokenParser::For < Twig::TokenParser

    def parse(token)
      lineno = token.lineno
      stream = @parser.stream
      targets = @parser.get_expression_parser.parse_assignment_expression
      stream.expect(:operator_type, 'in')
      seq = @parser.get_expression_parser.parse_expression
      ifexpr = nil
      if stream.next_if(:name_type, 'if')
        ifexpr = @parser.get_expression_parser.parse_expression;
      end
      stream.expect(:block_end_type)
      body = @parser.subparse([self, :decide_for_fork])
      if stream.next.value == 'else'
        stream.expect(:block_end_type)
        _else = @parser.subparse([self, :decide_for_end], true)
      else
        _else = nil
      end
      stream.expect(:block_end_type)
      if targets.length > 1
        key_target = targets.nodes[0]
        key_target = Twig::Node::Expression::AssignName.new(key_target.get_attribute('name'), key_target.lineno);
        value_target = targets.nodes[1]
        value_target = Twig::Node::Expression::AssignName.new(value_target.get_attribute('name'), value_target.lineno)
      else
        key_target = nil
        value_target = targets.nodes[0]
        value_target = Twig::Node::Expression::AssignName.new(value_target.get_attribute('name'), value_target.lineno)
      end
      if ifexpr
        check_loop_usage_condition(stream, ifexpr)
        check_loop_usage_body(stream, body)
      end
      Twig::Node::For.new(key_target, value_target, seq, ifexpr, body, _else, lineno, tag)
    end

    def decide_for_fork(token)
      token.check(['else'.freeze, 'endfor'.freeze])
    end

    def decide_for_end(token)
      token.check('endfor'.freeze)
    end

    # the loop variable cannot be used in the condition
    def check_loop_usage_condition(stream, node)
      if node.is_a?(Twig::Node::Expression::GetAttr) && node.get_node('node').is_a?(Twig::Node::Expression::Name) && 'loop' == node.get_node('node').get_attribute('name')
        raise Twig::Error::Syntax.new('The "loop" variable cannot be used in a looping condition.', node.lineno, stream.filename)
      end
      node.each do |n|
        if n
          check_loop_usage_condition(stream, n)
        end
      end
    end

    # check usage of non-defined loop-items
    # it does not catch all problems (for instance when a for is included into another or when the variable is used in an include)
    def check_loop_usage_body(stream, node)
      if node.is_a?(Twig::Node::Expression::GetAttr) && node.get_node('node').is_a?(Twig::Node::Expression::Name) && 'loop' == node.get_node('node').get_attribute('name')
        attribute = node.get_node('attribute');
        if attribute.is_a?(Twig::Node::Expression::Constant) && ['length', 'revindex0', 'revindex', 'last'].include?(attribute.get_attribute('value'))
          raise Twig::Error::Syntax.new("The \"loop.#{attribute.get_attribute('value')}\" variable is not defined when looping with a condition.", node.lineno, stream.filename)
        end
      end
      # should check for parent.loop.XXX usage
      if node.is_a?(Twig::Node::For)
        return
      end
      node.each do |n|
        if n
          check_loop_usage_body(stream, n)
        end
      end
    end

    def tag
      'for'.freeze
    end
  end
end
