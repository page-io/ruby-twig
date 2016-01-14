module Twig
  class Error < StandardError

    attr_reader :nested, :raw_backtrace

    # Constructor.
    #
    # Set both the line number and the filename to false to
    # disable automatic guessing of the original template name
    # and line number.
    #
    # Set the line number to -1 to enable its automatic guessing.
    # Set the filename to null to enable its automatic guessing.
    #
    # By default, automatic guessing is enabled.
    #
    # @param string    $message  The error message
    # @param int       lineno   The template line where the error occurred
    # @param string    $filename The template file name where the error occurred
    # @param Exception $previous The previous exception
    def initialize(message, lineno = -1, filename = nil, nested = $!)
      super(message)
      @nested = nested
      @lineno = lineno
      @filename = filename
      if (-1 == @lineno || nil == @filename)
        guess_template_info
      end
      @raw_message = message
      update_repr
    end

    # Gets the raw message.
    #
    # @return string The raw message
    def get_raw_message
      @raw_message
    end

    # Gets the filename where the error occurred.
    #
    # @return string The filename
    def get_template_file
      @filename
    end

    # Sets the filename where the error occurred.
    #
    # @param string $filename The filename
    def set_template_file(filename)
      @filename = filename
      update_repr
    end

    # Gets the template line where the error occurred.
    #
    # @return int The template line
    def get_template_line
      @lineno
    end

    # Sets the template line where the error occurred.
    #
    # @param int lineno The template line
    def set_template_line(lineno)
      @lineno = lineno
      update_repr
    end

    def guess
      guess_template_info
      update_repr
    end

    # # For PHP < 5.3.0, provides access to the getPrevious() method.
    # #
    # # @param string $method    The method name
    # # @param array  $arguments The parameters to be passed to the method
    # #
    # # @return Exception The previous exception or null
    # #
    # # raise BadMethodCallException
    # def __call($method, $arguments)
    #     if ('getprevious' == strtolower($method)) {
    #         return $this->previous;
    #     end
    #     throw new BadMethodCallException(sprintf('Method "Twig::Error::%s()" does not exist.', $method));
    # end

    # def appendMessage($rawMessage)
    #     $this->rawMessage .= $rawMessage;
    #     update_repr;
    # end

    # @internal
    def update_repr
    #     $this->message = $this->rawMessage;
    #     $dot = false;
    #     if ('.' == substr($this->message, -1)) {
    #         $this->message = substr($this->message, 0, -1);
    #         $dot = true;
    #     end
    #     $questionMark = false;
    #     if ('?' == substr($this->message, -1)) {
    #         $this->message = substr($this->message, 0, -1);
    #         $questionMark = true;
    #     end
    #     if (@filename) {
    #         if (is_string(@filename) || (is_object(@filename) && method_exists(@filename, '__toString'))) {
    #             $filename = sprintf('"%s"', @filename);
    #         else
    #             $filename = json_encode(@filename);
    #         end
    #         $this->message .= sprintf(' in %s', $filename);
    #     end
    #     if (@lineno && @lineno >= 0) {
    #         $this->message .= sprintf(' at line %d', @lineno);
    #     end
    #     if ($dot) {
    #         $this->message .= '.';
    #     end
    #     if ($questionMark) {
    #         $this->message .= '?';
    #     end
    end

    # @internal
    def guess_template_info
      # template = nil
      # template_class = nil
      # backtrace = debug_backtrace()
      # backtrace.each do |trace|
      #   if (trace['object'] && trace['object'].is_a?(Twig::Template) && 'Twig::Template' != trace['object'].class)
      #     current_class = trace['object'].class
      #     is_embed_container = 0 == strpos(template_class, current_class)
      #     if (nil == @filename || (@filename == trace['object'].get_template_name && !is_embed_container))
      #       template = trace['object']
      #       template_class = trace['object'].class
      #     end
      #   end
      # end
      # update template filename
      # if (nil != template && nil == @filename)
      #   @filename = template.get_template_name
      # end
      # if (nil == template || @lineno > -1)
      #   return
      # end
      # r = ReflectionObject.new(template)
      # file = r.get_filename
      # # hhvm has a bug where eval'ed files comes out as the current directory
      # if (is_dir(file))
      #     $file = ''
      # end
      # exceptions = [e = self]
      # while ((e.is_a?(self.class) || method_exists(e, 'getPrevious')) && e = e.get_previous)
      #   exceptions << e
      # end
      # while (e = exceptions.pop)
      #   traces = e.get_trace()
      #   array_unshift(traces, { 'file' => e.get_file, 'line' => e.lineno } )
      #   while (trace = traces.shift)
      #     if (!isset(trace['file']) || !isset(trace['line']) || $file != trace['file'])
      #       continue
      #     end
      #     template.get_debug_info.each do |code_line, templateLine|
      #       if (code_line <= trace['line'])
      #         # update template line
      #         @lineno = templateLine
      #         return
      #       end
      #     end
      #   end
      # end
    end

    def set_backtrace(backtrace)
      @raw_backtrace = backtrace
      if nested
        backtrace = backtrace - nested_raw_backtrace
        backtrace += ["#{nested.backtrace.first}: #{nested.message} (#{nested.class.name})"]
        backtrace += nested.backtrace[1..-1] || []
      end
      super(backtrace)
    end

    private

    def nested_raw_backtrace
     nested.respond_to?(:raw_backtrace) ? nested.raw_backtrace : nested.backtrace
    end


  end
end
