module Twig
  class Markup

    def initialize(content, charset)
      @content = content
      @charset = charset
    end

    def to_str
      @content
    end

    def count
      @content.length
    end
  end
end
