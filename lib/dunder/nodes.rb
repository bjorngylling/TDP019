module Dunder
  module Nodes

    class Node
      
      @@global_scope = {}

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

    class VariableAssignment < Node
      def initialize(name, value)
        @name = name
        @value = value
      end

      def eval(scope = @@global_scope)
        scope[@name.to_sym] = @value.is_node? ? @value.eval : @value
      end
    end

    class Variable < Node
      attr_accessor :name, :scope

      def initialize(name = nil)
        @name = name
      end

      def eval(scope = @@global_scope)
        if scope.include?(@name.to_sym)
          return scope[@name.to_sym]
        else
          if scope.has_key? "PARENTSCOPE"
            return eval(scope["PARENTSCOPE"])
          else
            return false
          end
        end
      end
    end
    
  end
end

