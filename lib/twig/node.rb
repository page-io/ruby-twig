module Twig
  class Node

    attr_reader :tag, :nodes, :attributes, :lineno

    # Constructor.
    #
    # The nodes are automatically made available as properties (@node).
    # The attributes are automatically made available as array items ($this['name']).
    #
    # @param array  nodes      An array of named nodes
    # @param array  attributes An array of attributes (should not be nodes)
    # @param int    lineno     The line number
    # @param string tag        The tag name associated with the Node
    def initialize(nodes = nil, attributes = nil, lineno = 0, tag = nil)
      @nodes = nodes || []
      @attributes = attributes || {}
      @lineno = lineno
      @tag = tag
    end

    # def to_s
    #   attributes = []
    #   @attributes.each do |name, value|
    #     attributes << "#{name}: #{value.to_s}"
    #   end
    #   repr = self.class.name + '(' + attributes.join(', ')
    #   unless @nodes.nil?
    #     @nodes.each do |node|
    #       noderexpr = []
    #       node.to_s.split("\n").each do |line|
    #         noderexpr << ' ' << line
    #       end
    #       repr << "  #{noderexpr.join("\n")}"
    #     end
    #     repr << ')'
    #   else
    #     repr << ')'
    #   end
    #   repr
    # end

    def ==(other)
      @tag == other.tag && @nodes == other.nodes
    end

    def compile(compiler)
      # puts "debug: node: #{self.inspect}"
      each do |node|
        node.compile(compiler)
      end
    end

    def get_line
      @lineno
    end

    def get_node_tag
      @tag
    end

    # Returns true if the attribute is defined.
    #
    # @param string name The attribute name
    #
    # @return bool true if the attribute is defined, false otherwise
    def has_attribute(name)
      @attributes.key?(name)
    end

    # Gets an attribute value by name.
    #
    # @param string name
    #
    # @return mixed
    def get_attribute(name)
      if !@attributes.key?(name)
        raise LogicException.new("Attribute \"#{name}\" does not exist for Node \"#{self.class.name}\".")
      end
      @attributes[name]
    end

    # Sets an attribute by name to a value.
    #
    # @param string name
    # @param mixed  value
    def set_attribute(name, value)
      @attributes[name] = value
    end

    # Removes an attribute by name.
    #
    # @param string name
    def remove_attribute(name)
      @attributes.delete(name)
    end

    # Returns true if the node with the given name exists.
    #
    # @param string name
    #
    # @return bool
    def has_node(name)
      @nodes.key?(name)
    end

    # Gets a node by name.
    #
    # @param string name
    #
    # @return Twig::Node
    def get_node(name)
      if !@nodes.key?(name)
        raise LogicException.new("Node \"#{name}\" does not exist for Node \"#{self.class.name}\".")
      end
      @nodes[name]
    end

    # Sets a node.
    #
    # @param name [String]
    # @param node [Twig::Node]
    def set_node(name, node)
      @nodes[name] = node
    end

    # Removes a node by name.
    #
    # @param string name
    def remove_node(name)
      @nodes.delete(name)
    end

    def length
      @nodes.length
    end

    def each(&block)
      if @nodes.is_a?(::Hash)
        @nodes.each_value(&block)
      else
        @nodes.each(&block)
      end
    end
  end
end
