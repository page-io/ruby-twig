module Twig
  class Token

    attr_reader :type, :value, :lineno

    # Constructor.
    #
    # @param int    type   The type of the token
    # @param string value  The token value
    # @param int    lineno The line position in the source
    def initialize(type, value, lineno)
      @type = type
      @value = value
      @lineno = lineno
    end


    # Tests the current token for a type and/or a value.
    #
    # Parameters may be:
    # * just type
    # * type and value (or array of possible values)
    # * just value (or array of possible values) (NAME_TYPE is used as type)
    #
    # @param type array|int          The type to test
    # @param values array|string|nil The token value
    #
    # @return [Boolean]
    def check(type, values = nil)
      if values.nil? && !type.is_a?(Symbol)
        values = type
        type = :name_type
      end
      (@type == type) && (
        values.nil? ||
        (values.is_a?(::Array) && values.include?(@value)) ||
        @value == values
      )
    end

    # Gets the line.
    #
    # @rturn int The source line
    def get_line
      @lineno
    end

    # Returns the english representation of a given type.
    #
    # @param int type The type as an integer
    #
    # @return string The string representation
    def self.type_to_english(type)
      case type
      when :text_type
        'text'
      when :block_start_type
        'begin of statement block'
      when :var_start_type
        'begin of print statement'
      when :block_end_type
        'end of statement block'
      when :var_end_type
        'end of print statement'
      when :name_type
        'name'
      when :number_type
        'number'
      when :string_type
        'string'
      when :operator_type
        'operator'
      when :punctuation_type
        'punctuation'
      when :interpolation_start_type
        'begin of string interpolation'
      when :interpolation_end_type
        'end of string interpolation'
      else
        raise LogicException.new("Token of type \"#{type}\" does not exist.")
      end
    end

  end
end
