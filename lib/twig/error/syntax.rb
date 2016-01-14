module Twig
  class Error::Syntax < Twig::Error

    def initialize(message, lineno = -1, filename = nil)
      super
    end

    # Tweaks the error message to include suggestions.
    #
    # @param string $name  The original name of the item that does not exist
    # @param array  $items An array of possible items
    def add_suggestions(name, items)
    #     if (!$alternatives = self::computeAlternatives($name, $items)) {
    #         return;
    #     end
    #     $this->appendMessage(sprintf(' Did you mean "%s"?', implode('", "', $alternatives)));
    end

    # # @internal
    # #
    # # To be merged with the addSuggestions() method in 2.0.
    # public static function computeAlternatives($name, $items)
    #     $alternatives = [];
    #     foreach ($items as $item) {
    #         $lev = levenshtein($name, $item);
    #         if ($lev <= strlen($name) / 3 || false !== strpos($item, $name)) {
    #             $alternatives[$item] = $lev;
    #         end
    #     end
    #     asort($alternatives);
    #     return array_keys($alternatives);
    # end
  end
end
