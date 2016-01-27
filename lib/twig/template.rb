module Twig
  class Template

    # protected $parent;
    @@cache = {}

    # Constructor.
    #
    # @param Twig::Environment env A Twig::Environment instance
    def initialize(env)
      @env = env
      @blocks = {}
      @parents = {}
      @traits = {}
    end

    # Returns the template name.
    #
    # @return string The template name
    def get_template_name
      raise NotImplementedError.new("#{self.class.name}#area is an abstract method.")
    end

    # # @deprecated since 1.20 (to be removed in 2.0)
    # def getEnvironment()
    #     @trigger_error('The '.__METHOD__.' method is deprecated since version 1.20 and will be removed in 2.0.', E_USER_DEPRECATED);
    #     return @env;
    # end

    # Returns the parent template.
    #
    # This method is for internal use only and should never be called
    # directly.
    #
    # @param array context
    #
    # @return Twig::TemplateInterface|false The parent template or false if there is no parent
    #
    # @internal
    def get_parent(context)
      unless @parent.nil?
        return @parent
      end
      begin
        parent = do_get_parent(context)
        if parent.nil?
          return nil
        end
        if parent.is_a?(Twig::Template)
          return @parents[parent.get_template_name] = parent
        end
        unless @parents.key?(parent)
          @parents[parent] = load_template(parent)
        end
      rescue Twig::Error::Loader => ex
        ex.set_template_file(nil)
        ex.guess
        raise
      end
      @parents[parent]
    end

    # protected function doGetParent(array context)
    #     return false;
    # end

    def is_traitable
      true
    end

    # Displays a parent block.
    #
    # This method is for internal use only and should never be called
    # directly.
    #
    # @param string name    The block name to display from the parent
    # @param array  context The context
    # @param array  blocks  The current set of blocks
    #
    # @internal
    def display_parent_block(name, context, blocks = [])
      name = name.to_s
      if @traits.key?(name)
        @traits[name][0].display_block(name, context, blocks, false)
      elsif (parent = get_parent(context))
        parent.display_block(name, context, blocks, false)
      else
        raise Twig::Error::Runtime.new(sprintf('The template has no parent and no traits defining the "%s" block', name), -1, get_template_name)
      end
    end

    # Displays a block.
    #
    # This method is for internal use only and should never be called
    # directly.
    #
    # @param string name      The block name to display
    # @param array  context   The context
    # @param array  blocks    The current set of blocks
    # @param bool   use_blocks Whether to use the current set of blocks
    #
    # @internal
    def display_block(name, context, blocks = {}, use_blocks = true)
      name = name.to_s
      if use_blocks && blocks.key?(name)
        template = blocks[name][0]
        block = blocks[name][1]
      elsif @blocks.key?(name)
        template = @blocks[name][0]
        block = @blocks[name][1]
      else
        template = nil
        block = nil
      end

      if !template.nil?
        # avoid RCEs when sandbox is enabled
        unless template.is_a?(Twig::Template)
          raise LogicException.new('A block must be a method on a Twig::Template instance.')
        end
        begin
          template.send(block.to_sym, context, blocks)
        rescue Twig::Error => ex
          unless ex.get_template_file
            ex.set_template_file(template.get_template_name)
          end
          # this is mostly useful for Twig::Error::Loader exceptions
          # see Twig::Error::Loader
          unless ex.get_template_line
            ex.set_template_line(-1)
            ex.guess
          end
          raise ex
        rescue => ex
          raise Twig::Error::Runtime.new("An exception has been thrown during the rendering of a template (\"#{ex.message}\").", -1, template.get_template_name, ex)
        end
      elsif (false != parent = get_parent(context))
        parent.display_block(name, context, @blocks.merge(blocks), false)
      end
    end

    # Renders a parent block.
    #
    # This method is for internal use only and should never be called
    # directly.
    #
    # @param string name    The block name to render from the parent
    # @param array  context The context
    # @param array  blocks  The current set of blocks
    #
    # @return string The rendered block
    #
    # @internal
    def render_parent_block(name, context, blocks = {})
      # ob_start();
      display_parent_block(name, context, blocks)
      # return ob_get_clean();
    end

    # Renders a block.
    #
    # This method is for internal use only and should never be called
    # directly.
    #
    # @param string name      The block name to render
    # @param array  context   The context
    # @param array  blocks    The current set of blocks
    # @param bool   use_blocks Whether to use the current set of blocks
    #
    # @return string The rendered block
    #
    # @internal
    def render_block(name, context, blocks = {}, use_blocks = true)
      # ob_start();
      display_block(name, context, blocks, use_blocks)
      # return ob_get_clean();
    end

    # Returns whether a block exists or not.
    #
    # This method is for internal use only and should never be called
    # directly.
    #
    # This method does only return blocks defined in the current template
    # or defined in "used" traits.
    #
    # It does not return blocks from parent templates as the parent
    # template name can be dynamic, which is only known based on the
    # current context.
    #
    # @param string name The block name
    #
    # @return bool true if the block exists, false otherwise
    #
    # @internal
    def has_block(name)
      @blocks.key?(name.to_s)
    end

    # Returns all block names.
    #
    # This method is for internal use only and should never be called
    # directly.
    #
    # @return array An array of block names
    #
    # @see hasBlock
    #
    # @internal
    def get_block_names
      @blocks.keys
    end

    def load_template(template, template_name = nil, line = nil, index = nil)
      begin
        if template.is_a?(::Array)
          return @env.resolve_template(template)
        end
        if template.is_a?(self.class)
          return template
        end
        return @env.load_template(template, index)
      rescue Twig::Error => ex
        if !ex.get_template_file
          ex.set_template_file(template_name ? template_name : get_template_name)
        end
        if ex.get_template_line
          raise
        end
        if !line
          ex.guess
        else
          ex.set_template_line(line)
        end
        raise
      end
    end

    # Returns all blocks.
    #
    # This method is for internal use only and should never be called
    # directly.
    #
    # @return array An array of blocks
    #
    # @see hasBlock
    #
    # @internal
    def get_blocks
      @blocks
    end

    # Returns the template source code.
    #
    # @return string|null The template source code or null if it is not available
    def get_source
      raise 'check this!'
        # _reflector = new ReflectionClass($this);
        # $file = _reflector.filename;
        # if (!file_exists($file)) {
        #     return;
        # end
        # $source = file($file, FILE_IGNORE_NEW_LINES);
        # array_splice($source, 0, _reflector.getEndLine());
        # $i = 0;
        # while (isset($source[$i]) && '/* */' == substr_replace($source[$i], '', 3, -2)) {
        #     $source[$i] = str_replace('*//* ', '*/', substr($source[$i], 3, -2));
        #     ++$i;
        # end
        # array_splice($source, $i);
        # return implode("\n", $source);
    end

    def display(context, blocks = {})
      display_with_error_handling(@env.merge_globals(context), @blocks.merge(blocks))
    end

    # {@inheritdoc}
    def render(context)
      # begin
        display(context)
      # rescue
      #   raise
      # end
    end

    def display_with_error_handling(context, blocks = {})
      begin
        do_display(context, blocks)
      rescue Twig::Error => ex
        unless ex.get_template_file
          ex.set_template_file(get_template_name)
        end
        # this is mostly useful for Twig::Error::Loader exceptions
        # @see (Twig::Error::Loader)
        #
        unless ex.get_template_line
          ex.set_template_line(-1)
          ex.guess
        end
        raise
      rescue => ex
        raise Twig::Error::Runtime.new("An exception has been thrown during the rendering of template \"#{get_template_name}\" (\"#{ex.message}\").", -1, get_template_name, ex)
      end
    end

    # Returns a variable from the context.
    #
    # This method is for internal use only and should never be called
    # directly.
    #
    # This method should not be overridden in a sub-class as this is an
    # implementation detail that has been introduced to optimize variable
    # access for versions of PHP before 5.4. This is not a way to override
    # the way to get a variable value.
    #
    # @param array  context           The context
    # @param string item              The variable to return from the context
    # @param bool   ignore_strict_check Whether to ignore the strict variable check or not
    #
    # @return mixed The content of the context variable
    #
    # raise Twig_Error_Runtime if the variable does not exist and Twig is running in strict mode
    #
    # @internal
    def get_context(context, item, ignore_strict_check = false)
      unless context.key?(item)
        if ignore_strict_check || !@env.is_strict_variables
          return
        end
        raise Twig::Error::Runtime.new("Variable \"#{item}\" does not exist", -1, get_template_name)
      end
      context[item]
    end

    # Returns the attribute value for a given array/object.
    #
    # @param object [Object] The object or array from where to get the item
    # @param item [String] The item to get from the array or object
    # @param arguments [Hash] An hash of arguments to pass if the item is an object method
    # @param call_type [Symbol] The type of attribute
    # @param is_defined_test [Boolean] Whether this is only a defined check
    # @param ignore_strict_check [Boolean] Whether to ignore the strict attribute check or not
    #
    # @return mixed The attribute value, or a Boolean when is_defined_test is true, or null when the attribute is not set and ignore_strict_check is true
    #
    # @raise Twig::Error::Runtime if the attribute does not exist and Twig is running in strict mode and is_defined_test is false
    def get_attribute(object, item, arguments = [], call_type = :any_call, is_defined_test = false, ignore_strict_check = false)
      # array
      if call_type != :method_call
        if object.is_a?(::Hash) && object.include?(item)
          return is_defined_test ? true : object[item]
        end

        if object.is_a?(::Array) && (item.to_i >= 0 && item.to_i < object.length)
          return is_defined_test ? true : object[item]
        end

        if :array_call == call_type || !object.is_a?(Object)
          if is_defined_test
            return false
          end
          if ignore_strict_check || !@env.is_strict_variables
            return
          end
          if object.is_a?(::Hash) || object.is_a?(::Array)
            if object.empty?
              message = "Key \"#{item}\" does not exist as the array is empty"
            else
              message = "Key \"#{item}\" does not exist on array"
            end
          elsif object.respond_to?(:[])
            message = "Key \"#{item}\" in object with [] access of class \"#{object.class}\" does not exist"
          elsif object.is_a?(Object)
            message = "Impossible to access a key \"#{item}\" on an object of class \"#{object.class}\" that does not implement [] method"
          elsif :array_call == call_type
            if object.nil?
              message = "Impossible to access a key (\"#{item}\") on a null variable"
            else
              message = "Impossible to access a key (\"#{item}\") on a #{object.class} variable (\"#{object}\")"
            end
          elsif object.nil?
            message = "Impossible to access an attribute (\"#{item}\") on a null variable"
          else
            message = "Impossible to access an attribute (\"#{item}\") on a #{object.class} variable (\"#{object}\")"
          end
          raise Twig::Error::Runtime.new(message, -1, get_template_name)
        end
      end

      unless object.is_a?(Object)
        if is_defined_test
          return false
        end
        if ignore_strict_check || !@env.is_strict_variables
          return
        end
        if object.nil?
          message = "Impossible to invoke a method (\"#{item}\") on a null variable"
        else
          message = "Impossible to invoke a method (\"#{item}\") on a #{gettype(object)} variable (\"#{object}\")"
        end
        raise Twig::Error::Runtime.new(message, -1, get_template_name)
      end

      # object property
      if :method_call != call_type && !object.is_a?(self.class) # Twig_Template does not have public properties, and we don't want to allow access to internal ones
        if object.respond_to?(item.to_sym)
          if is_defined_test
            return true
          end
          if @env.has_extension('sandbox')
            @env.get_extension('sandbox').check_property_allowed(object, item)
          end
          return object.item
        end
      end
      klass = object.class

      # object method
      @@cache[klass] ||= {}
      unless @@cache[klass]['methods']
        # get_class_methods returns all methods accessible in the scope, but we only want public ones to be accessible in templates
        if object.is_a?(self.class)
          _methods = {}
          klass.public_methods.each do |method|
            # Accessing the environment from templates is forbidden to prevent untrusted changes to the environment
            if :environment != method
              _methods[method] = true
            end
          end
          @@cache[klass]['methods'] = _methods
        else
          @@cache[klass]['methods'] = klass.public_methods
        end
      end
      _call = false
      _lcItem = item.to_sym
      if @@cache[klass]['methods'].include?(_lcItem)
        _method = item
      elsif @@cache[klass]['methods'].include?("get#{_lcItem}".to_sym)
        _method = 'get' + item;
      elsif @@cache[klass]['methods'].include?("is#{_lcItem}".to_sym)
        _method = 'is' + item
      elsif @@cache[klass]['methods'].include?(:call)
        _method = item
        _call = true
      else
        if is_defined_test
          return false
        end
        if ignore_strict_check || !@env.is_strict_variables
          return
        end
        raise Twig::Error::Runtime.new("Method \"#{item}\" for object \"#{object.class.name}\" does not exist", -1, get_template_name)
      end
      if is_defined_test
        return true
      end
      if @env.has_extension('sandbox')
        @env.get_extension('sandbox').check_method_allowed(object, _method)
      end
      # Some objects raise exceptions when they have __call, and the method we try
      # to call is not supported. If ignoreStrictCheck is true, we should return null.
      begin
        ret = call_user_func_array([object, method]), arguments
      rescue BadMethodCallException
        if _call && (ignore_strict_check || !@env.is_strict_variables)
          return
        end
        raise
      end
      # useful when calling a template method from a template
      # this is not supported but unfortunately heavily used in the Symfony profiler
      if object.is_a?(Twig::Template)
        return ret == '' ? '' : Twig::Markup.new(ret, @env.get_charset)
      end
      ret
    end

    def call_user_func(callable, *args)
      callable[0].send(callable[1].to_sym, args)
    end

    def merge_context(parent, context)
      parent.keys.each do |key|
        parent[key] = context[key] if context.key?(key)
      end
      parent
    end
  end
end
