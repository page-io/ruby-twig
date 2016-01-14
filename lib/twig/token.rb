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

    # # Returns the constant representation (internal) of a given type.
    # #
    # # @param int  type  The type as an integer
    # # @param bool short Whether to return a short representation or not
    # #
    # # @return string The string representation
    # def self.type_to_string(type, short = false)
    #     switch (type) {
    #         case :eof_type
    #             $name = 'EOF_TYPE';
    #             break;
    #         case :text_type
    #             $name = 'TEXT_TYPE';
    #             break;
    #         case self::BLOCK_START_TYPE
    #             $name = 'BLOCK_START_TYPE';
    #             break;
    #         case self::VAR_START_TYPE:
    #             $name = 'VAR_START_TYPE';
    #             break;
    #         case self::BLOCK_END_TYPE:
    #             $name = 'BLOCK_END_TYPE';
    #             break;
    #         case self::VAR_END_TYPE:
    #             $name = 'VAR_END_TYPE';
    #             break;
    #         case self::NAME_TYPE:
    #             $name = 'NAME_TYPE';
    #             break;
    #         case self::NUMBER_TYPE:
    #             $name = 'NUMBER_TYPE';
    #             break;
    #         case self::STRING_TYPE:
    #             $name = 'STRING_TYPE';
    #             break;
    #         case self::OPERATOR_TYPE:
    #             $name = 'OPERATOR_TYPE';
    #             break;
    #         case self::PUNCTUATION_TYPE:
    #             $name = 'PUNCTUATION_TYPE';
    #             break;
    #         case self::INTERPOLATION_START_TYPE:
    #             $name = 'INTERPOLATION_START_TYPE';
    #             break;
    #         case self::INTERPOLATION_END_TYPE:
    #             $name = 'INTERPOLATION_END_TYPE';
    #             break;
    #         default:
    #             raise LogicException.new(sprintf('Token of type "%s" does not exist.', type));
    #     end
    #     return short ? $name : 'Twig_Token::'.$name;
    # end

    # Returns the english representation of a given type.
    #
    # @param int type The type as an integer
    #
    # @return string The string representation
    def self.type_to_english(type)
      case type
      when :eof_type
        'end of template'
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
