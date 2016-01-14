module Twig
  class TokenParser::Set < Twig::TokenParser

    def parse(token)
      lineno = token.lineno
      stream = @parser.get_stream
      names = @parser.get_expression_parser.parse_assignment_expression
      capture = false
      if stream.next_if(:operator_type, '=')
        values = @parser.get_expression_parser.parse_multitarget_expression
        stream.expect(:block_end_type)
        if names.length != values.length
          raise Twig::Error::Syntax.new('When using set, you must have the same number of variables and assignments.', stream.current_token.lineno, stream.filename)
        end
      else
         capture = true
         if names.length > 1
           raise Twig::Error::Syntax.new('When using set with a block, you cannot have a multi-target.', stream.current_token.lineno, stream.filename)
         end
         stream.expect(:block_end_type)
         values = @parser.subparse([self, :decide_block_end], true)
         stream.expect(:block_end_type)
      end
      Twig::Node::Set.new(capture, names, values, lineno, tag)
    end

    def decide_block_end(token)
      token.check('endset'.freeze)
    end

    def tag
      'set'.freeze
    end
  end
end
