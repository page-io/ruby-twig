module Twig
  class Runtime

    #  Cycles over a value.
    #
    #  @param ArrayAccess|array values   An array or an ArrayAccess instance
    #  @param int               $position The cycle position
    #
    #  @return string The next value in the cycle
    def self.twig_cycle(values, position)
      unless is_array(values) && !values.is_a?(ArrayAccess)
        return values
      end
      values[position % values.length]
    end

    MAX_RANDOM = 2147483647

    #  Returns a random value depending on the supplied parameter type:
    #  - a random item from a Traversable or array
    #  - a random character from a string
    #  - a random integer between 0 and the integer parameter.
    #
    #  @param env [Twig::Environment] A Twig::Environment instance
    #  @param values [Traversable|Array|Intiger|String] The values to pick a random item from
    #
    #  @raise Twig::Error::Runtime When values is an empty array (does not apply to an empty string which is returned as is).
    #
    #  @return mixed A random value from the given sequence
    def self.twig_random(env, values = nil)
      if nil == values
        return rand(MAX_RANDOM)
      end
      if values.is_a?(Numeric)
        return values < 0 ? -rand(-values) : rand(values)
      end
      if values.is_a?(Traversable)
        values = iterator_to_array(values)
      elsif values.is_a?(String)
        if ('' == values)
          return ''
        end
        if (nil != charset = env.get_charset)
          if 'UTF-8' != charset
            values = twig_convert_encoding(values, 'UTF-8', charset)
          end
          # unicode version of str_split()
          # split at all positions, but not after the start and not before the end
          values = preg_split('/(?<!^)(?!$)/u', values)
          if charset != 'UTF-8'
            values.each do |value|
              values[i] = twig_convert_encoding(value, charset, 'UTF-8')
            end
          end
        else
          return values[rand(values.length)]
        end
      end
      unless values.is_a?(::Array)
        return values
      end
      if values.length == 0
        raise Twig::Error::Runtime.new('The random function cannot pick from an empty array.')
      end
      values.sample
    end

    # php to ruby date format conversion table
    DATE_FORMAT_CONVERTER = {
      '%' => '%%', # escape
      # Day
      'd' => '%d', # Day of the month, 2 digits with leading zeros	01 to 31
      'D' => '%a', #	A textual representation of a day, three letters	Mon through Sun
      'j' => '%-d', #	Day of the month without leading zeros	1 to 31
      'l' => '%A', # (lowercase 'L')	A full textual representation of the day of the week	Sunday through Saturday
      'N' => '%u', #	ISO-8601 numeric representation of the day of the week (added in PHP 5.1.0)	1 (for Monday) through 7 (for Sunday)
      'S' => '%!S', #	English ordinal suffix for the day of the month, 2 characters	st, nd, rd or th. Works well with j
      'w' => '%w', #	Numeric representation of the day of the week	0 (for Sunday) through 6 (for Saturday)
      'z' => '%!z', #	The day of the year (starting from 0)	0 through 365
      # Week
      'W' => '%V', #	ISO-8601 week number of year, weeks starting on Monday (added in PHP 4.1.0)	Example: 42 (the 42nd week in the year)
      # Month
      'F' => '%B', #	A full textual representation of a month, such as January or March	January through December
      'm' => '%m', #	Numeric representation of a month, with leading zeros	01 through 12
      'M' => '%b', #	A short textual representation of a month, three letters	Jan through Dec
      'n' => '%-m', #	Numeric representation of a month, without leading zeros	1 through 12
      't' => '%!t', #	Number of days in the given month	28 through 31
      # Year	---	---
      'L' => '%!L', #	Whether it's a leap year	1 if it is a leap year, 0 otherwise.
      'o' => '%G', #	ISO-8601 year number. This has the same value as Y, except that if the ISO week number (W) belongs to the previous or next year, that year is used instead. (added in PHP 5.1.0)	Examples: 1999 or 2003
      'Y' => '%Y', #	A full numeric representation of a year, 4 digits	Examples: 1999 or 2003
      'y' => '%y', #	A two digit representation of a year	Examples: 99 or 03
      # Time
      'a' => '%P', #	Lowercase Ante meridiem and Post meridiem	am or pm
      'A' => '%p', #	Uppercase Ante meridiem and Post meridiem	AM or PM
      'B' => '%!B', #	Swatch Internet time	000 through 999
      'g' => '%l', #	12-hour format of an hour without leading zeros	1 through 12
      'G' => '%-k', #	24-hour format of an hour without leading zeros	0 through 23
      'h' => '%I', #	12-hour format of an hour with leading zeros	01 through 12
      'H' => '%H', #	24-hour format of an hour with leading zeros	00 through 23
      'i' => '%M', #	Minutes with leading zeros	00 to 59
      's' => '%S', #	Seconds, with leading zeros	00 through 59
      'u' => '%6N', #	Microseconds (added in PHP 5.2.2). Note that date() will always generate 000000 since it takes an integer parameter, whereas DateTime::format() does support microseconds if DateTime was created with microseconds.	Example: 654321
      # Timezone
      'e' => '%!e', #	Timezone identifier (added in PHP 5.1.0)	Examples: UTC, GMT, Atlantic/Azores
      'I' => '%!I', # (capital i)	Whether or not the date is in daylight saving time	1 if Daylight Saving Time, 0 otherwise.
      'O' => '%z', #	Difference to Greenwich time (GMT) in hours	Example: +0200
      'P' => '%:z', #	Difference to Greenwich time (GMT) with colon between hours and minutes (added in PHP 5.1.3)	Example: +02:00
      'T' => '%Z', #	Timezone abbreviation	Examples: EST, MDT ...
      'Z' => '%!Z', #	Timezone offset in seconds. The offset for timezones west of UTC is always negative, and for those east of UTC is always positive.	-43200 through 50400
      # Full Date/Time
      'c' => '%FT%T%:z', #	ISO 8601 date (added in PHP 5)	2004-02-12T15:19:21+00:00
      'r' => '%a, %d %b %Y %T %z', #	» RFC 2822 formatted date	Example: Thu, 21 Dec 2000 16:01:07 +0200
      'U' => '%s', #	Seconds since the Unix Epoch (January 1 1970 00:00:00 GMT)	See also time()
    }
    DATE_FORMAT_CONVERTER_REGEXP = /(#{DATE_FORMAT_CONVERTER.keys.sort!.reverse!.join('|')})/

    #  Converts a date to the given format.
    #
    #  <pre>
    #    {{ post.published_at|date("m/d/Y") }}
    #  </pre>
    #
    #  @param env [Twig::Environment]                   A Twig::Environment instance
    #  @param date [DateTime,DateInterval,string]       A date
    #  @param format [String,nil]                       The target (PHP) format, nil to use the default
    #  @param timezone [DateTimeZone,String,nil,false]  The target timezone, nil to use the default, false to leave unchanged
    #
    #  @return string The formatted date
    def self.twig_date_format_filter(env, date, format = nil, timezone = nil)
      # if date.is_a?(DateInterval)
      #   return twig_date_interval_format_filter(env, date_interval, format, timezone)
      # end

      date = Date.today if date.nil?

      if format.nil?
        format = env.get_extension('core').get_date_format
      end
      format = format.gsub(DATE_FORMAT_CONVERTER_REGEXP,DATE_FORMAT_CONVERTER)
      if format.include?('%!')
        # String includes unsupported formats
        format.gsub!(/%!([SztLBeIZ])/,'\1')
      end
      twig_date_converter(env, date, timezone).strftime(format)
    end

    def self.twig_date_interval_format_filter(env, date_interval, format = nil, timezone = nil)
      if format.nil?
        format = env.get_extension('core').get_date_interval_format
      end
      format = format.gsub(DATE_FORMAT_CONVERTER_REGEXP,DATE_FORMAT_CONVERTER)

      date.strftime(format)
    end

    #  Returns a new date object modified.
    #
    #  <pre>
    #    {{ post.published_at|date_modify("-1day")|date("m/d/Y") }}
    #  </pre>
    #
    #  @param Twig_Environment env      A Twig_Environment instance
    #  @param DateTime|string  date     A date
    #  @param string           modifier A modifier string
    #
    #  @return DateTime A new date object
    def self.twig_date_modify_filter(env, date, modifier)
      date = twig_date_converter(env, date, false)
      result_date = date.modify(modifier)
      # This is a hack to ensure PHP 5.2 support and support for DateTimeImmutable
      # DateTime::modify does not return the modified DateTime object < 5.3.0
      # and DateTimeImmutable does not modify date.
      nil == result_date ? date : result_date
    end

    #  Converts an input to a DateTime instance.
    #
    #  <pre>
    #     {% if date(user.created_at) < date('+2days') %}
    #       {# do something #}
    #     {% endif %}
    #  </pre>
    #
    #  @param Twig_Environment                       env      A Twig_Environment instance
    #  @param DateTime|DateTimeInterface|string|nil date     A date
    #  @param DateTimeZone|string|nil|false         timezone The target timezone, nil to use the default, false to leave unchanged
    #
    #  @return DateTime A DateTime instance
    def self.twig_date_converter(env, date = nil, timezone = nil)
      return date
      # determine the timezone
      if false != timezone
        if (nil == timezone)
          timezone = env.get_extension('core').get_timezone
        elsif !timezone.is_a?(DateTimeZone)
          timezone = DateTimeZone.new(timezone)
        end
      end
      # immutable dates
      if date.is_a?(DateTimeImmutable)
        return false != timezone ? date.set_timezone(timezone) : date
      end
      if date.is_a?(DateTime) || date.is_a?(DateTimeInterface)
        date = date.dup
        if false != timezone
          date.set_timezone(timezone)
        end
        return date
      end
      if nil == date || 'now' == date
        return DateTime.new(date, false != timezone ? timezone : env.get_extension('core').get_timezone())
      end
      as_string = date.to_s
      if (ctype_digit(as_string) || (!empty(as_string) && '-' == as_string[0] && ctype_digit(substr(as_string, 1))))
        date = DateTime.new('@'.date)
      else
        date = DateTime.new(date, env.get_extension('core').get_timezone)
      end
      if false != timezone
        date.set_timezone(timezone)
      end
      date
    end

    #  Replaces strings within a string.
    #
    #  @param string            str  String to replace in
    #  @param array|Traversable from Replace values
    #  @param string|nil       to   Replace to, deprecated (@see http://php.net/manual/en/function.strtr.php)
    #
    #  @return string
    def self.twig_replace_filter(str, from, to = nil)
      if from.is_a?(Traversable)
        from = iterator_to_array(from)
      elsif is_string(from) && is_string(to)
        warn 'Using "replace" with character by character replacement is deprecated'
        return strtr(str, from, to)
      elsif !is_array(from)
        raise Twig::Error::Runtime.new(sprintf('The "replace" filter expects an array or "Traversable" as replace values, got "%s".',is_object(from) ? from.class : gettype(from)))
      end
      return strtr(str, from)
    end

    #  Rounds a number.
    #
    #  @param int|float value     The value to round
    #  @param int|float precision The rounding precision
    #  @param string    method    The method to use for rounding
    #
    #  @return int|float The rounded number
    def self.twig_round(value, precision = 0, method = 'common')
      if 'common' == method
        return round(value, precision)
      end
      if 'ceil' != method && 'floor' != method
        raise Twig::Error::Runtime.new('The round filter only supports the "common", "ceil", and "floor" methods.')
      end
      method(value * pow(10, precision)) / pow(10, precision)
    end

    #  Number format filter.
    #
    #  All of the formatting options can be left nil, in that case the defaults will
    #  be used.  Supplying any of the parameters will override the defaults set in the
    #  environment object.
    #
    #  @param env [Twig::Environment]       A Twig::Environment instance
    #  @param number mixed                  A float/int/string of the number to format
    #  @param decimal [Integer]             The number of decimal points to display.
    #  @param decimal_point [String]        The character(s) to use for the decimal point.
    #  @param thousand_sep [String]         The character(s) to use for the thousands separator.
    #
    #  @return string The formatted number
    def self.twig_number_format_filter(env, number, decimal = nil, decimal_point = nil, thousand_sep = nil)
      require 'active_support'
      require 'active_support/core_ext/numeric/conversions'

      defaults = env.get_extension('core').get_number_format

      decimal ||= defaults[:decimal]
      decimal_point ||= defaults[:decimal_point]
      thousand_sep ||= defaults[:thousand_separator]

      rounded_number = (Float(number) * (10 ** decimal)).round.to_f / 10 ** decimal
      ("%01.#{decimal}f" % rounded_number).to_f.to_s(:delimited, separator: decimal_point, delimiter: thousand_sep)
    end

    #  URL encodes (RFC 3986) a string as a path segment or an array as a query string.
    #
    #  @param string|array url A URL or an array of query parameters
    #
    #  @return string The URL encoded value
    def self.twig_urlencode_filter(url)
      if is_array(url)
        return http_build_query(url, '', '&')
      end
      return rawurlencode(url)
    end

    #
    # JSON encodes a variable.
    #
    #  @param mixed value   The value to encode.
    #  @param int   options Bitmask consisting of JSON_HEX_QUOT, JSON_HEX_TAG, JSON_HEX_AMP, JSON_HEX_APOS, JSON_NUMERIC_CHECK, JSON_PRETTY_PRINT, JSON_UNESCAPED_SLASHES, JSON_FORCE_OBJECT
    #
    #  @return mixed The JSON encoded value
    #
    def self.twig_jsonencode_filter(value, options = 0)
      if value.is_a?(Twig::Markup)
        value = value.to_s
      elsif is_array(value)
        array_walk_recursive(value, '_twig_markup2string')
      end
      json_encode(value, options)
    end

    # def _twig_markup2string(&value)
    #     if (value.is_a?(Twig_Markup)
    #         value = (string) value;
    #     end
    # end

    #  Merges an array with another one.
    #
    #  <pre>
    #   {% set items = { 'apple': 'fruit', 'orange': 'fruit' } %}
    #
    #   {% set items = items|merge({ 'peugeot': 'car' }) %}
    #
    #   {# items now contains { 'apple': 'fruit', 'orange': 'fruit', 'peugeot': 'car' } #}
    #  </pre>
    #
    #  @param arr1 [Array,Hash,#to_a] An object to merge
    #  @param arr2 [Array,Hash,#to_a] An object to merge
    #
    #  @return array The merged array
    def self.twig_array_merge(arr1, arr2)
      if arr1.is_a?(::Hash)
        unless arr2.is_a?(::Hash)
          raise Twig::Error::Runtime.new("Can only merge an hash with another hash, got \"#{arr2.class}\" as second argument.")
        end
        return arr1.merge(arr2)
      elsif !arr1.respond_to?(:to_a)
        raise Twig::Error::Runtime.new("The merge filter only works with arrays or hash, got \"#{arr1.class}\" as first argument.")
      end
      if !arr2.respond_to?(:to_a)
        raise Twig::Error::Runtime.new("The merge filter only works with arrays or hash, got \"#{arr2.class}\" as second argument.")
      end
      arr1.to_a | arr2.to_a
    end

    #  Slices a variable.
    #
    #  @param Twig_Environment env          A Twig_Environment instance
    #  @param mixed            item         A variable
    #  @param int              start        Start of the slice
    #  @param int              length       Size of the slice
    #  @param bool             preserve_keys Whether to preserve key or not (when the input is an array)
    #
    #  @return mixed The sliced variable
    def self.twig_slice(env, item, start, length = nil, preserve_keys = false)
      offset = start.to_i
      length = length ? length.to_i : 1

      if item.is_a?(::Array)
        item.slice(offset, length) || []
      elsif item.is_a?(::Hash)
        keys_to_slice = item.keys[offset..(offset + length)]
        item.slice(keys_to_slice) || {}
      else
        item.to_s.slice(offset, length) || ''
      end
    end

    #  Returns the first element of the item.
    #
    #  @param Twig_Environment env  A Twig_Environment instance
    #  @param mixed            item A variable
    #
    #  @return mixed The first element of the item
    def self.twig_first(env, item)
      elements = twig_slice(env, item, 0,1, false)
      elements.is_a?(::String) ? elements : elements.first
    end

    #  Returns the last element of the item.
    #
    #  @param Twig_Environment env  A Twig_Environment instance
    #  @param mixed            item A variable
    #
    #  @return mixed The last element of the item
    def self.twig_last(env, item)
      elements = twig_slice(env, item, -1,1, false)
      elements.is_a?(::String) ? elements : elements.last
    end

    #  Joins the values to a string.
    #
    #  The separator between elements is an empty string per default, you can define it with the optional parameter.
    #
    #  <pre>
    #   {{ [1, 2, 3]|join('|') }}
    #   {# returns 1|2|3 #}
    #
    #   {{ [1, 2, 3]|join }}
    #   {# returns 123 #}
    #  </pre>
    #
    #  @param array  value An array
    #  @param string glue  The separator
    #
    #  @return string The concatenated string
    def self.twig_join_filter(value, glue = '')
      if value.is_a?(::Array)
        value.join(glue)
      elsif value.is_a?(::Hash)
        value.values.join(glue)
      end
    end

    #  Splits the string into an array.
    #
    #  <pre>
    #   {{ "one,two,three"|split(',') }}
    #   {# returns [one, two, three] #}
    #
    #   {{ "one,two,three,four,five"|split(',', 3) }}
    #   {# returns [one, two, "three,four,five"] #}
    #
    #   {{ "123"|split('') }}
    #   {# returns [1, 2, 3] #}
    #
    #   {{ "aabbcc"|split('', 2) }}
    #   {# returns [aa, bb, cc] #}
    #  </pre>
    #
    #  @param [Twig::Environment] env      A Twig::Environment instance
    #  @param String              value     A string
    #  @param String              delimiter The delimiter
    #  @param int                 limit     The limit
    #
    #  @return array The split string as an array
    def self.twig_split_filter(env, value, delimiter, limit = nil)
      unless delimiter.empty?
        return nil == limit ? value.split(delimiter) : value.split(delimiter, limit)
      end
      if nil == limit || limit <= 1
        return value.split ''
      end
      value.scan(/.{1,#{limit.to_i}}/)
    end

    def self.twig_default_filter(value, default = '')
      value.nil? ? default : value
    end

    #  Returns the keys for the given array.
    #
    #  It is useful when you want to iterate over the keys of an array:
    #
    #  <pre>
    #   {% for key in array|keys %}
    #       {# ... #}
    #   {% endfor %}
    #  </pre>
    #
    #  @param array array An array
    #
    #  @return array The keys
    def self.twig_get_array_keys_filter(array)
      if array.is_a?(Traversable)
        return array_keys(iterator_to_array(array))
      end
      unless is_array(array)
        return []
      end
      array_keys(array)
    end

    #  Reverses a variable.
    #
    #  @param Twig_Environment         env          A Twig_Environment instance
    #  @param array|Traversable|string item         An array, a Traversable instance, or a string
    #  @param bool                     preserve_keys Whether to preserve key or not
    #
    #  @return mixed The reversed input
    def self.twig_reverse_filter(env, item, preserve_keys = false)
      if item.is_a?(Traversable)
        return array_reverse(iterator_to_array(item), preserve_keys)
      end
      if is_array(item)
        return array_reverse(item, preserve_keys)
      end
      if nil != charset = env.get_charset()
        string = item.to_s;
        if 'UTF-8' != charset
          item = twig_convert_encoding(string, 'UTF-8', charset)
        end
        preg_match_all('/./us', item, matches)
        string = implode('', array_reverse(matches[0]))
        if 'UTF-8' != charset
          string = twig_convert_encoding(string, charset, 'UTF-8')
        end
        return string;
      end
      return strrev(item.to_s)
    end

    #  Sorts an array.
    #
    #  @param array|Traversable array
    #
    #  @return array
    def self.twig_sort_filter(array)
      if array.is_a?(Traversable)
        array = iterator_to_array(array)
      elsif !is_array(array)
        raise Twig::Error::Runtime.new(sprintf('The sort filter only works with arrays or "Traversable", got "%s".', gettype(array)))
      end
      asort(array)
      return array
    end

    #  @internal
    def self.twig_in_filter(value, *compare)
      # binding.pry
      compare.each do |cmp|
        if cmp.is_a?(::Array)
          return true if cmp.include?(value)
        elsif cmp.is_a?(::String) && (value.is_a?(String) || value.is_a?(::Integer) || value.is_a?(::Float))
          return true if cmp.include?(value.to_s)
        elsif cmp.is_a?(::Hash)
          return true if cmp.has_value?(value)
        end
      end

      return false;
    end


    #  Escapes a string.
    #
    #  @param env [Twig::Environment] A Twig::Environment instance
    #  @param string [String]         The value to be escaped
    #  @param strategy [String]       The escaping strategy
    #  @param charset [String]        The charset
    #  @param autoescape [Boolean]    Whether the function is called by the auto-escaping feature (true) or by the developer (false)
    #
    #  @return string
    def self.twig_escape_filter(env, string, strategy = 'html', charset = nil, autoescape = false)
      if autoescape && string.is_a?(Twig::Markup)
        return string
      end

      unless string.is_a?(String)
        string = string.to_s
      end

      if charset.nil?
        charset = env.get_charset
      end

      case strategy
      when 'html'
        # see http://php.net/htmlspecialchars
        # Using a static variable to avoid initializing the array
        # each time the function is called. Moving the declaration on the
        # top of the function slow downs other escaping strategies.
        if htmlspecialchars_charsets.nil?
          htmlspecialchars_charsets = {
            'ISO-8859-1' => true, 'ISO8859-1' => true,
            'ISO-8859-15' => true, 'ISO8859-15' => true,
            'utf-8' => true, 'UTF-8' => true,
            'CP866' => true, 'IBM866' => true, '866' => true,
            'CP1251' => true, 'WINDOWS-1251' => true, 'WIN-1251' => true,
            '1251' => true,
            'CP1252' => true, 'WINDOWS-1252' => true, '1252' => true,
            'KOI8-R' => true, 'KOI8-RU' => true, 'KOI8R' => true,
            'BIG5' => true, '950' => true,
            'GB2312' => true, '936' => true,
            'BIG5-HKSCS' => true,
            'SHIFT_JIS' => true, 'SJIS' => true, '932' => true,
            'EUC-JP' => true, 'EUCJP' => true,
            'ISO8859-5' => true, 'ISO-8859-5' => true, 'MACROMAN' => true,
          }
        end
        if htmlspecialchars_charsets.key?(charset)
          return htmlspecialchars(string, ENT_QUOTES | ENT_SUBSTITUTE, charset)
        end
        if htmlspecialchars_charsets.key?(charset.upcase)
          # cache the lowercase variant for future iterations
          htmlspecialchars_charsets[charset] = true
          return htmlspecialchars(string, ENT_QUOTES | ENT_SUBSTITUTE, charset)
        end
        string = twig_convert_encoding(string, 'UTF-8', charset)
        string = htmlspecialchars(string, ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8')
        return twig_convert_encoding(string, charset, 'UTF-8')

      when 'js'
        # escape all non-alphanumeric characters
        # into their \xHH or \uHHHH representations
        if ('UTF-8' != charset)
          string = twig_convert_encoding(string, 'UTF-8', charset)
        end
        if (0 == strlen(string) ? false : (1 == preg_match('/^./su', string) ? false : true))
          raise Twig::Error::Runtime.new('The string to escape is not a valid UTF-8 string.')
        end
        string = preg_replace_callback('#[^a-zA-Z0-9,\._]#Su', '_twig_escape_js_callback', string)
        if 'UTF-8' != charset
          string = twig_convert_encoding(string, charset, 'UTF-8')
        end
        return string

      when 'css'
        if 'UTF-8' != charset
          string = twig_convert_encoding(string, 'UTF-8', charset)
        end
        if (string.length == 0 ? false : (1 == preg_match('/^./su', string) ? false : true))
          raise Twig::Error::Runtime.new('The string to escape is not a valid UTF-8 string.');
        end
        string = preg_replace_callback('#[^a-zA-Z0-9]#Su', '_twig_escape_css_callback', string);
        if 'UTF-8' != charset
          string = twig_convert_encoding(string, charset, 'UTF-8')
        end
        return string

      when 'html_attr'
        if ('UTF-8' != charset)
          string = twig_convert_encoding(string, 'UTF-8', charset)
        end
        if (0 == string.length ? false : (1 == preg_match('/^./su', string) ? false : true))
          raise Twig::Error::Runtime.new('The string to escape is not a valid UTF-8 string.')
        end
        string = preg_replace_callback('#[^a-zA-Z0-9,\.\-_]#Su', '_twig_escape_html_attr_callback', string)
        if ('UTF-8' != charset)
          string = twig_convert_encoding(string, charset, 'UTF-8')
        end
        return string

      when 'url'
        return rawurlencode(string)

      else
        if escapers.nil?
          escapers = env.get_extension('core').get_escapers
        end
        if escapers.key?(strategy)
          return call_user_func(escapers[strategy], env, string, charset)
        end
        valid_strategies = implode(', ', array_merge(['html', 'js', 'url', 'css', 'html_attr'], escapers.keys))
        raise Twig::Error::Runtime.new("Invalid escaping strategy \"#{strategy}\" (valid ones: #{valid_strategies}).")
      end
    end

    #  @internal
    # def self.twig_escape_filter_is_safe(Twig_Node $filterArgs)
    #     foreach ($filterArgs as $arg) {
    #         if ($arg.is_a?(Twig::Node::Expression::Constant) {
    #             return array($arg.get_attribute('value'));
    #         end
    #         return [];
    #     end
    #     return array('html');
    # end

    # if (function_exists('mb_convert_encoding')) {
    #     def self.twig_convert_encoding(string, to, from)
    #         return mb_convert_encoding(string, to, from);
    #     end
    # end elsif (function_exists('iconv')) {
    #     def self.twig_convert_encoding(string, to, from)
    #         return iconv(from, to, string);
    #     end
    # else
    #     def self.twig_convert_encoding(string, to, from)
    #         raise Twig::Error::Runtime.new('No suitable convert encoding function (use UTF-8 as your encoding or install the iconv or mbstring extension).');
    #     end
    # end

    # def _twig_escape_js_callback(matches)
    #     $char = matches[0];
    #     # \xHH
    #     if (!isset($char[1])) {
    #         return '\\x'.strtoupper(substr('00'.bin2hex($char), -2));
    #     end
    #     # \uHHHH
    #     $char = twig_convert_encoding($char, 'UTF-16BE', 'UTF-8');
    #     return '\\u'.strtoupper(substr('0000'.bin2hex($char), -4));
    # end

    # def _twig_escape_css_callback(matches)
    #     $char = matches[0];
    #     # \xHH
    #     if (!isset($char[1])) {
    #         $hex = ltrim(strtoupper(bin2hex($char)), '0');
    #         if (0 == strlen($hex)) {
    #             $hex = '0';
    #         end
    #         return '\\'.$hex.' ';
    #     end
    #     # \uHHHH
    #     $char = twig_convert_encoding($char, 'UTF-16BE', 'UTF-8');
    #     return '\\'.ltrim(strtoupper(bin2hex($char)), '0').' ';
    # end

    #  This function is adapted from code coming from Zend Framework.
    #
    #  @copyright Copyright (c) 2005-2012 Zend Technologies USA Inc. (http://www.zend.com)
    #  @license   http://framework.zend.com/license/new-bsd New BSD License
    # def _twig_escape_html_attr_callback(matches)
    #     /*
    #      * While HTML supports far more named entities, the lowest common denominator
    #      * has become HTML5's XML Serialisation which is restricted to the those named
    #      * entities that XML supports. Using HTML entities would result in this error:
    #      *     XML Parsing Error: undefined entity
    #      */
    #     static $entityMap = array(
    #         34 => 'quot', /* quotation mark */
    #         38 => 'amp',  /* ampersand */
    #         60 => 'lt',   /* less-than sign */
    #         62 => 'gt',   /* greater-than sign */
    #     );
    #     $chr = matches[0];
    #     $ord = ord($chr);
    #     /*
    #      * The following replaces characters undefined in HTML with the
    #      * hex entity for the Unicode replacement character.
    #      */
    #     if (($ord <= 0x1f && $chr != "\t" && $chr != "\n" && $chr != "\r") || ($ord >= 0x7f && $ord <= 0x9f)) {
    #         return '&#xFFFD;';
    #     end
    #     /*
    #      * Check if the current character to escape has a name entity we should
    #      * replace it with while grabbing the hex value of the character.
    #      */
    #     if (strlen($chr) == 1) {
    #         $hex = strtoupper(substr('00'.bin2hex($chr), -2));
    #     else
    #         $chr = twig_convert_encoding($chr, 'UTF-16BE', 'UTF-8');
    #         $hex = strtoupper(substr('0000'.bin2hex($chr), -4));
    #     end
    #     $int = hexdec($hex);
    #     if (array_key_exists($int, $entityMap)) {
    #         return sprintf('&%s;', $entityMap[$int]);
    #     end
    #     /*
    #      * Per OWASP recommendations, we'll use hex entities for any other
    #      * characters where a named entity does not exist.
    #      */
    #     return sprintf('&#x%s;', $hex);
    # end

    #
    # Returns the length of a variable.
    #
    # @param Twig::Environment env   A Twig::Environment instance
    # @param mixed            thing A variable
    #
    # @return int The length of the value
    #
    def self.twig_length_filter(env, thing)
      thing.respond_to?(:length) ? thing.length : 0
    end

    #
    # Returns the length of a variable.
    #
    # @param [String]            A string variable
    #
    # @return [String] Returns the string with all letters in upper case
    #
    def self.twig_upper_filter(string)
      string.upcase
    end

    #
    # Returns the length of a variable.
    #
    # @param [String]            A string variable
    #
    # @return [String] Returns the string with all letters in down case
    #
    def self.twig_lower_filter(string)
      string.downcase
    end

    #
    # Returns a titlecased string.
    #
    # @param Twig::Environment env    A Twig_Environment instance
    # @param string           string A string
    #
    # @return string The titlecased string
    #
    def self.twig_title_string_filter(string)
      string.downcase.gsub(/\b(?<!['â`])[a-z]/) { $&.capitalize }
    end

    #
    # Returns a capitalized string.
    #
    # @param Twig_Environment env    A Twig_Environment instance
    # @param string           string A string
    #
    # @return string The capitalized string
    #
    def self.twig_capitalize_string_filter(env, string)
      string.capitalize
    end

    #  @internal
    # def self.twig_ensure_traversable(seq)
    #     if ($seq.is_a?(Traversable || is_array($seq)) {
    #         return $seq;
    #     end
    #     return [];
    # end

    #  Checks if a variable is empty.
    #
    #  <pre>
    #  {# evaluates to true if the foo variable is nil, false, or the empty string #}
    #  {% if foo is empty %}
    #      {# ... #}
    #  {% endif %}
    #  </pre>
    #
    #  @param mixed value A variable
    #
    #  @return bool true if the value is empty, false otherwise
    def self.twig_test_empty(value)
      if value.respond_to?(:length)
        return 0 == value.length
      end
      '' == value || false == value || nil == value || [] == value
    end

    #  Checks if a variable is traversable.
    #
    #  <pre>
    #  {# evaluates to true if the foo variable is an array or a traversable object #}
    #  {% if foo is traversable %}
    #      {# ... #}
    #  {% endif %}
    #  </pre>
    #
    #  @param mixed value A variable
    #
    #  @return bool true if the value is traversable
    def self.twig_test_iterable(value)
      value.respond_to?(:each)
    end

    #  Renders a template.
    #
    #  @param env [Twig::Environment]
    #  @param array            $context
    #  @param string|array     template      The template to render or an array of templates to try consecutively
    #  @param array            variables     The variables to pass to the template
    #  @param bool             with_context
    #  @param bool             ignore_missing Whether to ignore missing templates or not
    #  @param bool             sandboxed     Whether to sandbox the template or not
    #
    #  @return string The rendered template
    def self.twig_include(env, context, template, variables = [], with_context = true, ignore_missing = false, sandboxed = false)
      already_sandboxed = false
      sandbox = nil
      if with_context
        variables = array_merge(context, variables)
      end
      if is_sandboxed = sandboxed && env.has_extension('sandbox')
        sandbox = env.get_extension('sandbox')
        unless already_sandboxed = sandbox.is_sandboxed()
          sandbox.enable_sandbox
        end
      end
      result = nil
      begin
        result = env.resolve_template(template).render(variables)
      rescue Twig::Error::Loader => ex
        unless ignore_missing
          if is_sandboxed && !already_sandboxed
            sandbox.disable_sandbox
          end
          raise ex
        end
      end
      if is_sandboxed && !already_sandboxed
        sandbox.disable_sandbox
      end
      result
    end

    #  Returns a template content without rendering it.
    #
    #  @param Twig_Environment env
    #  @param string           name          The template name
    #  @param bool             ignore_missing Whether to ignore missing templates or not
    #
    #  @return string The template source
    def self.twig_source(env, name, ignore_missing = false)
      begin
        return env.loader.get_source(name)
      rescue Twig::Error::Loader
        unless ignore_missing
          raise
        end
      end
    end

    #  Provides the ability to get constants from instances as well as class/global constants.
    #
    #  @param string      $constant The name of the constant
    #  @param nil|object $object   The object to get the constant from
    #
    #  @return string
    def self.twig_constant(constant, object = nil)
      if (nil != object)
        constant = (object).class+'::'+constant
      end
      constant(constant)
    end

    #  Batches item.
    #
    #  @param array items An array of items
    #  @param int   size  The size of the batch
    #  @param mixed fill  A value used to fill missing items
    #
    #  @return array
    def self.twig_array_batch(items, size, fill = nil)
      array = items
      if items.is_a?(::Hash)
        array = items.values
      end
      sliced_array = array.each_slice(size).to_a
      if fill and sliced_array.last.count < size
        last_entry = sliced_array.last
        last_entry.fill fill, last_entry.count, size - last_entry.count
      end
      sliced_array
    end

    #  Returns absolute value of a given number.
    #  Returned number will be of same type as given value (number or float)
    #
    #  @param mixed value A numeric value
    #
    #  @return mixed
    def self.twig_abs(value)
      if value.is_a?(Numeric)
        return value.abs
      end
      return nil
    end

    #  Gives a range of values starting at start_value and ending at end_value, in numerical order
    #  Both start_value and end_value will be consider as possible parts of the range
    #
    #  @param int start_value Number to start range of values at
    #  @param int end_value Number to end range of values at
    #  @param int step Returned range values will skip step by step
    #
    #  @return array
    def self.twig_range(start_value, end_value, step = 1)
      Range.new(start_value,end_value).step(step).to_a
    end
  end
end
