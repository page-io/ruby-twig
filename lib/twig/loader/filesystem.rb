module Twig
  module Loader
    class Filesystem

      MAIN_NAMESPACE = '__main__'

      # Constructor.
      #
      # @param string|array paths A path or an array of paths where to look for templates
      def initialize(paths = nil)
        @paths = {}
        @cache = {}
        @error_cache = {}

        set_paths(paths) if paths
      end

      # Returns the paths to the templates.
      #
      # @param string namespace A path namespace
      #
      # @return array The array of paths where to look for templates
      def get_paths(namespace = MAIN_NAMESPACE)
        @paths[namespace] || []
      end

      # Returns the path namespaces.
      #
      # The main namespace is always defined.
      #
      # @return array The array of defined namespaces
      def get_namespaces
        @paths.keys
      end

      # Sets the paths where templates are stored.
      #
      # @param string|array paths     A path or an array of paths where to look for templates
      # @param string       namespace A path namespace
      def set_paths(paths, namespace = MAIN_NAMESPACE)
        unless paths.is_a?(::Array)
          paths = [paths]
        end
        @paths[namespace] = []
        paths.each do |path|
          add_path(path, namespace)
        end
      end

      # Adds a path where templates are stored.
      #
      # @param string path      A path where to look for templates
      # @param string namespace A path name
      #
      # raise Twig::Error::Loader
      def add_path(path, namespace = MAIN_NAMESPACE)
        # invalidate the cache
        @cache = @error_cache = {}
        unless Dir.exist?(path)
          raise Twig::Error::Loader.new("The \"#{path}\" directory does not exist.")
        end
        @paths[namespace] << Pathname.new(path).realpath.to_s
      end

      # # Prepends a path where templates are stored.
      # #
      # # @param string path      A path where to look for templates
      # # @param string namespace A path name
      # #
      # # raise Twig::Error::Loader
      # def prepend_path(path, namespace = MAIN_NAMESPACE)
      #   # invalidate the cache
      #   @cache = @error_cache = []
      #   unless Dir.exist?(path)
      #     raise Twig::Error::Loader.new("The \"#{path}\" directory does not exist.")
      #   end
      #   path = rtrim(path, '/\\')
      #   if (!isset(@paths[namespace]))
      #       @paths[namespace][] = path
      #   else
      #       array_unshift(@paths[namespace], path)
      #   end
      # end

      def get_source(name)
        File.read(find_template(name))
      end

      def get_cache_key(name)
        find_template(name)
      end

      def exists(name)
        name = normalize_name(name)
        if @cache.key?(name)
          return true
        end
        begin
          return false != find_template(name, false)
        rescue Twig::Error::Loader
          return false
        end
      end

      def is_fresh(name, time)
        File.mtime(find_template(name)) <= time
      end

      def find_template(name, raise_error = true)
        name = normalize_name(name)
        if @cache.key?(name)
          return @cache[name]
        end
        if @error_cache.key?(name)
          unless raise_error
            return false
          end
          raise Twig::Error::Loader.new(@error_cache[name])
        end
        validate_name(name)
        namespace, shortname = parse_name(name)
        unless @paths.key?(namespace)
          @error_cache[name] = "There are no registered paths for namespace \"#{namespace}\"."
          unless raise_error
            return false
          end
          raise Twig::Error::Loader.new(@error_cache[name])
        end
        @paths[namespace].each do |path|
          full_path = Pathname.new(path).join(shortname)
          if full_path.file?
            return @cache[name] = full_path.realpath.to_s
          end
        end
        @error_cache[name] = "Unable to find template \"#{name}\" (looked into: #{@paths[namespace].join(', ')})."

        raise Twig::Error::Loader.new(@error_cache[name]) if raise_error
        false
      end

      def parse_name(name, default = MAIN_NAMESPACE)
        if '@' == name[0]
          unless name.match(/\A@(.+?)\/(.*)/)
            raise Twig::Error::Loader.new "Malformed namespaced template name \"%#{name}\" (expecting \"@namespace/template_name\")."
          end
          return [$1, $2]
        end
        [default, name]
      end

      def normalize_name(name)
        name.gsub(/\/\/+/, '/').gsub('\\', '/')
      end

      def validate_name(name)
        if name.include?("\0")
          raise Twig::Error::Loader.new("Looks like (#{name}) contains null byte.")
        end
        name = Pathname.new(name).cleanpath.to_s
        if name.to_s =~ /\A\/?\.\./
          raise Twig::Error::Loader.new("Looks like you try to load a template outside configured directories (#{name}).")
        end
      end
    end
  end
end
