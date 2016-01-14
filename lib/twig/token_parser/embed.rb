module Twig
  class TokenParser::Embed < Twig::TokenParser

    def parse(token)
      stream = @parser.get_stream
      parent = @parser.get_expression_parser.parse_expression
      variables, only, ignore_missing = parse_arguments
      # inject a fake parent to make the parent() function work
      stream.inject_tokens([
        Twig::Token.new(:block_start_type, '', token.lineno),
        Twig::Token.new(:name_type, 'extends', token.lineno),
        Twig::Token.new(:string_type, '__parent__', token.lineno),
        Twig::Token.new(:block_end_type, '', token.lineno)
      ])
      _module = @parser.parse(stream, [self, :decide_block_end], true)
      # override the parent with the correct one
      _module.set_node('parent', parent)
      @parser.embedTemplate(_module)
      stream.expect(:block_end_type)
      Twig::Node::Embed.new(_module.get_attribute('filename'), _module.get_attribute('index'), variables, only, ignore_missing, token.lineno, tag)
    end

    def decide_block_end(token)
      token.check('endembed'.freeze)
    end

    def tag
      'embed'.freeze
    end
  end
end
