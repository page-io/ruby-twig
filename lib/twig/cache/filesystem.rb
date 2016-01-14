module Twig
  class Cache::Filesystem
    FORCE_BYTECODE_INVALIDATION = 1
    # private directory;
    # private options;

    def initialize(directory, options = 0)
      @directory = directory
      @options = options
    end

    def generate_key(name, class_name)
      hash = hash('sha256', class_name);
      @directory+'/'+hash[0].hash[1]+'/'+hash+'.rb'
    end

    def load(key)
      @include_once key
    end

    def write(key, content)
      dir = dirname(key)
      if !is_dir(dir)
        if !@mkdir(dir, 0777, true) && !is_dir(dir)
          raise RuntimeException.new("Unable to create the cache directory (#{dir}).")
        end
      elsif (!is_writable(dir))
        raise RuntimeException.new("Unable to write in the cache directory (#{dir}).")
      end
      tmp_file = tempnam(dir, basename(key));
      if @file_put_contents(tmp_file, content) && @rename(tmp_file, key)
        @chmod(key, 0666 & ~umask());
        if (FORCE_BYTECODE_INVALIDATION == (@options & FORCE_BYTECODE_INVALIDATION))
          # Compile cached file into bytecode cache
          if (function_exists('opcache_invalidate'))
            opcache_invalidate(key, true)
          elsif (function_exists('apc_compile_file'))
            apc_compile_file(key);
          end
        end
        return
      end
      raise RuntimeException.new("Failed to write cache file \"#{key}\".")
    end

    def get_timestamp(key)
      if !file_exists(key)
        return 0
      end
      @filemtime(key)
    end
end
