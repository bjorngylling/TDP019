module Dunder
  module Nodes

    class Node

      def is_node?
        true
      end

    end

    class Addition < Node
      attr_accessor :lh, :rh

      def eval()
        (@lh.is_node? ? @lh.eval : @lh) + (@rh.is_node? ? @rh.eval : @rh)
      end
    end

    class Subtraction < Node
      attr_accessor :lh, :rh

      def eval()
        (@lh.is_node? ? @lh.eval : @lh) - (@rh.is_node? ? @rh.eval : @rh)
      end
    end

    class Multiplication < Node
      attr_accessor :lh, :rh

      def eval()
        (@lh.is_node? ? @lh.eval : @lh) * (@rh.is_node? ? @rh.eval : @rh)
      end
    end

    class Division < Node
      attr_accessor :lh, :rh

      def eval()
        (@lh.is_node? ? @lh.eval : @lh) / (@rh.is_node? ? @rh.eval : @rh)
      end
    end

  end
end

