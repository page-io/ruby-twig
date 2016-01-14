module Twig
  module Extension
    class Optimizer
      include Twig::Extension

      def initialize(optimizers = -1)
        @optimizers = optimizers
      end

      def get_node_visitors
        [Twig::NodeVisitor::Optimizer.new(@optimizers)]
      end

      def get_name
        'optimizer'
      end
    end
  end
end
