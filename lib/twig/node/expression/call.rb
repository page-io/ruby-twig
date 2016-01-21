module Twig
  class Node::Expression::Call < Node::Expression

    def compile_callable(compiler)
      needs_closing_parenthesis = false
      if (has_attribute(:callable) && callable = get_attribute(:callable))

        if callable.is_a?(String)
          compiler.raw(callable)
        elsif callable.is_a?(::Array) && callable[0].is_a?(Twig::Extension)
          compiler.raw("@env.get_extension(\'#{callable[0].get_name}\').#{callable[1]}")
        else
          type = get_attribute(:type)
          compiler.raw("call_user_func(@env.get_#{type}(\'#{get_attribute('name')}\').callable, ")
          needs_closing_parenthesis = true
        end
      else
        compiler.raw(get_attribute(:thing).compile)
      end

      compile_arguments(compiler)

      if needs_closing_parenthesis
        compiler.raw(')')
      end
    end

    def compile_arguments(compiler)
      compiler.raw('(')

      first = true

      if has_attribute(:needs_environment) && get_attribute(:needs_environment)
        compiler.raw('@env')
        first = false
      end

      if has_attribute(:needs_context) && get_attribute(:needs_context)
        unless first
          compiler.raw(', ')
        end
        compiler.raw('_context')
        first = false
      end

      if has_attribute('arguments')
        get_attribute('arguments').each do |argument|
          unless first
            compiler.raw(', ')
          end
          compiler.string(argument)
          first = false
        end
      end

      if has_node('node')
        unless first
          compiler.raw(', ')
        end
        compiler.subcompile(get_node('node'))
        first = false
      end

      if arguments = get_node('arguments')
        arguments = get_arguments(get_attribute(:callable), arguments)
        arguments.each do |node|
          unless first
            compiler.raw(', ')
          end
          compiler.subcompile(node)
          first = false
        end
      end

      compiler.raw(')')
    end

    # @param callable
    # @param arguments A Twig::Node with the arguments
    # @return An Array of Twig::Node with the arguments definitions
    def get_arguments(callable, arguments)
      call_type = get_attribute(:type)
      call_name = get_attribute('name')

      parameters = {}
      named = false

      arguments.nodes.each do |name, node|
        if !name.is_a?(Integer)
          named = true
          name = normalize_name(name) #??
        elsif named
          raise Twig::Error::Syntax.new("Positional arguments cannot be used after named arguments for #{call_type} \"#{call_name}\".")
        end

        parameters[name] = node
      end

      is_variadic = has_attribute(:is_variadic) && get_attribute(:is_variadic)
      if !named && !is_variadic
        return parameters.values
      end

      unless callable
        if named
          message = "Named arguments are not supported for #{call_type} \"#{call_name}\"."
        else
          message = "Arbitrary positional arguments are not supported for #{call_type} \"#{call_name}\"."
        end

        raise LogicException.new(message)
      end

      # manage named arguments
      callable_parameters = get_callable_parameters(callable, is_variadic).map{|x| x[1]=x[1].to_s; x}

      arguments = []
      names = []
      missing_arguments = []
      optional_arguments = []
      pos = 0;
      callable_parameters.each do |callable_parameter|
        name = callable_parameter[1]
        names << name

        if parameters.key?(name)
          if parameters.key?(pos)
            raise Twig::Error::Syntax.new("Argument \"#{name}\" is defined twice for #{call_type} \"#{call_name}\".")
          end

          if missing_arguments.any?
            raise Twig::Error::Syntax.new("Argument \"#{name}\" could not be assigned for #{call_type} \"#{call_name}(#{names.join(', ')})\" because it is mapped to an internal PHP function which cannot determine default value for optional argument#{missing_arguments.length > 1 ? 's' : ''} \"#{missing_arguments.join(', ')}\".")
          end
          arguments |= optional_arguments
          arguments << parameters[name]
          parameters.delete(name)
          optional_arguments = []

        elsif parameters.key?(pos)
          arguments |= optional_arguments
          arguments << parameters[pos]
          parameters.delete(pos)
          optional_arguments = []
          pos = pos + 1

        elsif callable_parameter[0] == :opt
        #   optional_arguments << Twig::Node::Expression::Constant.new(callable_parameter.get_default_value, -1)
        # elsif callable_parameter.is_optional
          if parameters.empty?
            break
          else
            missing_arguments << name
          end
        else
          raise Twig::Error::Syntax.new("Value for argument \"#{name}\" is required for #{call_type} \"#{call_name}\".")
        end
      end

      if is_variadic
        arbitrary_arguments = Twig::Node::Expression::Hash.new([], -1)
        parameters.each do |key, value|
          arbitrary_arguments.add_element(value, Twig::Node::Expression::Constant.new(key, -1))
          parameters.delete(key)
        end

        if arbitrary_arguments.nodes.any?
          arguments |= optional_arguments
          arguments << arbitrary_arguments
        end
      end

      if parameters.any?
        unknown_parameter = nil
        parameters.each do |parameter|
          if parameter.is_a?(Twig::Node)
            unknown_parameter = parameter
            break
          end
        end

        raise Twig::Error::Syntax.new("Unknown argument#{parameters.length > 1 ? 's' : ''} \"#{parameters.keys.join(', ')}\" for #{call_type} \"#{call_name}(#{names.join(', ')})\".", unknown_parameter ? unknown_parameter.line : -1)
      end

      arguments
    end

    def normalize_name(name)
      name.gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2').gsub(/([a-z\d])([A-Z])/, '\1_\2').downcase
    end

    protected

      def get_callable_method(callable)
        if callable.is_a?(::Array)
          method = callable.pop
          object = callable[0]
          if object.is_a?(String)
            object = object.split('::').reduce(Object){ |obj, ref| obj.const_get(ref.to_sym) }
          end
          object.method(method.to_sym)
        elsif callable.is_a?(Proc)
          callable.method(:call)
        elsif callable.is_a?(String)
          object = callable.split('::')
          method = object.pop
          method = method.split('.')
          if method.length > 1
            object << method[0]
            method = method[1]
          else
            method = method[0]
          end
          object = object.reduce(Object){ |obj, ref| obj.const_get(ref.to_sym) }

          object.method(method.to_sym)
        else
          nil
        end
      end

      def get_callable_parameters(callable, is_variadic=nil)
        r = get_callable_method(callable)

        parameters = r.parameters

        if has_node('node') # TODO! chech this!
          parameters.shift
        end
        if has_attribute(:needs_environment) && get_attribute(:needs_environment)
          parameters.shift
        end
        if has_attribute(:needs_context) && get_attribute(:needs_context)
          parameters.shift
        end
        if has_attribute('arguments') && nil != get_attribute('arguments')
          get_attribute('arguments').each do |argument|
            parameters.shift
          end
        end
        # if is_variadic
        #   argument = parameters.last
        #   if (argument && argument.is[] && argument.is_default_value_available && [] == argument.get_default_value)
        #     parameters.pop
        #   else
        #     callable_name = r.name
        #     if r.get_declaring_class
        #       callable_name = r.get_declaring_class.name + '::' + callable_name
        #     end
        #
        #     raise LogicException.new("The last parameter of \"#{callable_name}\" for #{get_attribute(:type)} \"#{get_attribute('name')}\" must be an array with default value, eg. \"array $arg = []\"\.")
        #   end
        # end
        parameters
      end

  end
end
