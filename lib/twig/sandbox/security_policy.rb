module Twig
  module Sandbox
    class SecurityPolicy

      def initialize(allowed_tags = [], allowed_filters = [], allowed_methods = [], allowed_properties = [], allowed_functions = [])
        @allowed_tags = allowed_tags
        @allowedilters = allowed_filters
        set_allowed_methods(allowed_methods)
        @allowed_properties = allowed_properties
        @allowed_functions = allowed_functions
      end

      def set_allowed_tags(tags)
        @allowed_tags = tags
      end

      def set_allowed_filters(filters)
        @allowedilters = filters
      end

      def set_allowed_methods(methods)
        @allowed_methods = []
        methods.each do |klass, m|
          @allowed_methods[klass] = (m.is_a?(::Array) ? m : [m]).map(&:downcase)
        end
      end

      def set_allowed_properties(properties)
        @allowed_properties = properties;
      end

      def set_allowed_functions(functions)
        @allowed_functions = functions
      end

      def check_security(tags, filters, functions)
        tags.each do |tag|
          if !@allowed_tags.include?(tag)
            raise Twig::Sandbox::SecurityNotAllowedTagError.new(sprintf('Tag "%s" is not allowed.', tag), tag)
          end
        end
        filters.each do |filter|
          if !@allowed_filters.include?(filter)
            raise Twig::Sandbox::SecurityNotAllowedFilterError.new(sprintf('Filter "%s" is not allowed.', filter), filter)
          end
        end
        functions.each do |function|
          if !@allowed_functions.include?(function)
            raise Twig::Sandbox::SecurityNotAllowedFunctionError.new(sprintf('Function "%s" is not allowed.', function), function)
          end
        end
      end

      def check_method_allowed(obj, method)
          if obj.is_a?(Twig::Template) || obj.is_a?(Twig::Markup)
            return true
          end
          allowed = false
          method = method.downcase
          @allowed_methods.each do |klass, methods|
            if obj.is_a?(klass)
              allowed = methods.include?(method)
              break
            end
          end
          unless allowed
            raise Twig::Sandbox::SecurityError.new(sprintf('Calling "%s" method on a "%s" object is not allowed.', method, obj.class.name))
          end
      end

      def check_property_allowed(obj, property)
        allowed = false
        @allowed_properties.each do |klass, properties|
          if obj.is_a?(klass)
            allowed = (properties.is_a?(::Array) ? properties : [properties]).include?(property)
            break
          end
        end
        unless allowed
          raise Twig::Sandbox::SecurityError.new(sprintf('Calling "%s" property on a "%s" object is not allowed.', property, obj.class.name));
        end
      end
    end
  end
end
