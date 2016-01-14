module Twig
  module Loader
    class Chain

      #
      # Constructor.
      #
      # @param Twig::LoaderInterface[] $loaders An array of loader instances
      #
      def initialize(loaders = [])
        @loaders = []
        @has_source_cache = {}
        loaders.each do |loader|
          add_loader(loader)
        end
      end

      #
      # Adds a loader instance.
      #
      # @param Twig::Loader loader A Loader instance
      #
      def add_loader(loader)
        @loaders << loader
        @has_source_cache = {}
      end

      #
      # {@inheritdoc}
      #
      def get_source(name)
        exceptions = []
        @loaders.each do |loader|
          if loader.exists(name)
            begin
              return loader.get_source(name)
            rescue Twig::Error::Loader => ex
              exceptions << ex.message
            end
          end
        end
        raise Twig::Error::Loader.new("Template \"#{name}\" is not defined#{(exceptions.any? ? ' ('+exceptions.join(', ')+')' : '')}.")
      end

      #
      # {@inheritdoc}
      #
      def exists(name)
        name = name.to_s
        if @has_source_cache.key?(name)
          return @has_source_cache[name]
        end
        @loaders.each do |loader|
          if loader.exists(name)
            return @has_source_cache[name] = true
          end
        end
        has_source_cache[name] = false
      end

      #
      # {@inheritdoc}
      #
      def get_cache_key(name)
        exceptions = []
        @loaders.each do |loader|
          if loader.exists(name)
            begin
              return loader.get_cache_key(name)
            rescue Twig::Error::Loader => ex
              exceptions << "#{loader.class.name}: #{ex.message}"
            end
          end
        end
        raise Twig::Error::Loader.new("Template \"#{name}\" is not defined#{(exceptions.any? ? ' ('+exceptions.join(', ')+')' : '')}.")
      end

      #
      # {@inheritdoc}
      #
      def is_fresh(name, time)
        exceptions = []
        @loaders.each do |loader|
          if loader.exists(name)
            begin
              return loader.is_fresh(name, time)
            rescue Twig::Error::Loader => ex
              exceptions << "#{loader.class.name}: #{ex.message}"
            end
          end
        end
        raise Twig::Error::Loader.new("Template \"#{name}\" is not defined#{(exceptions.any? ? ' ('+exceptions.join(', ')+')' : '')}.")
      end
    end
  end
end
