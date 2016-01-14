module Twig
  module Loader
    class Array

      def initialize(templates = {})
        @templates = templates
      end

      # Adds or overrides a template.
      #
      # @param string name     The template name
      # @param string template The template source
      def set_template(name, template)
        @templates[name] = template
      end

      # {@inheritdoc}
      def get_source(name)
        check_template_name(name)
        @templates[name]
      end

      # {@inheritdoc}
      def exists(name)
        @templates.key?(name)
      end

      # {@inheritdoc}
      def get_cache_key(name)
        get_source(name)
      end

      # {@inheritdoc}
      def is_fresh(name, time)
        check_template_name(name)
        true
      end

      protected

        def check_template_name(name)
          raise Twig::Error::Loader.new("Template \"#{name}\" is not defined") unless exists(name)
        end
    end
  end
end
