module Twig
  class Node::Expression::Hash < Node::Expression

    def initialize(elements, lineno)
      super(elements, nil, lineno)
    end

    def get_key_value_pairs
      pairs = []
      @nodes.each_slice(2) do |key, value|
        pairs << {
          'key' => key,
          'value' => value
        }
      end
      pairs
    end

    def has_element(key)
      get_key_value_pairs.each do |pair|
        # we compare the string representation of the keys
        # to avoid comparing the line numbers which are not relevant here.
        if key == pair['key']
          return true
        end
      end

      false
    end

    def add_element(value, key)
      @nodes << key << value
    end

    def compile(compiler)
      compiler.raw('{')
      _first = true
      get_key_value_pairs.each do |pair|
        if !_first
          compiler.raw(', ');
        end
        _first = false

        compiler
          .subcompile(pair['key'])
          .raw(' => ')
          .subcompile(pair['value'])
      end
      compiler.raw('}')
    end

  end
end
