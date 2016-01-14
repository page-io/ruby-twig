module Twig
  module Extension
    class Sandbox
      include Twig::Extension

      # protected $sandboxedGlobally;
      # protected $sandboxed;
      # protected policy;

      def initialize(policy, sandboxed = false)
          @policy = policy
          @sandboxed_globally = sandboxed
      end

      # Returns the token parser instances to add to the existing list.
      #
      # @return array An array of Twig::TokenParser or Twig::TokenParserBroker instances
      #
      def get_token_parsers
        [Twig::TokenParser::Sandbox.new]
      end

      # Returns the node visitor instances to add to the existing list.
      #
      # @return Twig::NodeVisitor[] An array of Twig::NodeVisitorInterface instances
      #
      def get_node_visitors
        [Twig::NodeVisitor::Sandbox.new]
      end

      def enable_sandbox
        @sandboxed = true
      end

      def disable_sandbox
        @sandboxed = false
      end

      def is_sandboxed
        @sandboxed_globally || @sandboxed
      end

      def is_sandboxed_globally
        @sandboxed_globally
      end

      def set_security_policy(policy)
        @policy = policy
      end

      def get_security_policy
        @policy
      end

      def checkSecurity(tags, filters, functions)
        if (is_sandboxed)
          @policy.check_security(tags, filters, functions)
        end
      end

      def check_method_allowed(obj, method)
        if is_sandboxed
          @policy.check_method_allowed(obj, method)
        end
      end

      def check_property_allowed(obj, method)
        if is_sandboxed
          @policy.check_property_allowed(obj, method)
        end
      end

      def ensure_to_string_allowed(obj)
        if is_sandboxed && is_object(obj)
          @policy.check_method_allowed(obj, 'to_str')
        end
        obj
      end

      # Returns the name of the extension.
      #
      # @return string The extension name
      #
      def get_name
        'sandbox'
      end
    end
  end
end
