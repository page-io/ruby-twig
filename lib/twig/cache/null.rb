module Twig
  module Cache
    class Null

      def generate_key(name, class_name)
        ''
      end

      def write(key, content)
      end

      def load(key)
      end

      def get_timestamp(key)
        0
      end
    end
  end
end
