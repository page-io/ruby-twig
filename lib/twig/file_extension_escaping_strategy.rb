module Twig
  class FileExtensionEscapingStrategy

    #
    # Guesses the best autoescaping strategy based on the file name.
    #
    # @param filename [String] The template file name
    #
    # @return String|false The escaping strategy name to use or false to disable
    #
    def guess(filename)
      case Pathname.new(filename).extname
      when'.js'
        return 'js'
      when '.css'
        return 'css'
      when '.txt'
        return false
      else
        return 'html'
      end
    end
  end
end
