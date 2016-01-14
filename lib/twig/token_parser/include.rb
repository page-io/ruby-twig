module Twig
  class TokenParser::Include < Twig::TokenParser

    def parse(token)
      expr = @parser.get_expression_parser.parse_expression
      variables, only, ignore_missing = parse_arguments
      Twig::Node::Include.new(expr, variables, only, ignore_missing, token.lineno, tag)
    end

    def parse_arguments
      stream = @parser.get_stream
      ignore_missing = false
      if stream.next_if(:name_type, 'ignore'.freeze)
        stream.expect(:name_type, 'missing'.freeze)
        ignore_missing = true
      end
      variables = nil
      if stream.next_if(:name_type, 'with'.freeze)
        variables = @parser.get_expression_parser.parse_expression
      end
      only = false
      if (stream.next_if(:name_type, 'only'.freeze))
        only = true
      end
      stream.expect(:block_end_type)
      [variables, only, ignore_missing]
    end

    def tag
      'include'.freeze
    end
  end
end
