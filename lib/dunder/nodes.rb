module Dunder
  module Nodes

    class Node

      @@global_scope = {}

      def is_node?
        true
      end

    end

    class StatementList < Node
      def initialize(statement)
        @statement_list = []
        @statement_list << statement
      end

      def <<(statement_list)
        @statement_list + statement_list.list
        self
      end

      def list
        @statement_list
      end

      def eval()
        result = nil
        @statement_list.each do |stmt|
          result = stmt.eval
        end

        return result
      end
    end

    class DString
      def initialize(value)
        @value = value
      end

      def eval()
        @value
      end
    end

    class DInteger
      def initialize(value)
        @value = value
      end

      def eval()
        @value
      end
    end

    class DFloat
      def initialize(value)
        @value = value
      end

      def eval()
        @value
      end
    end

    class DBoolean
      def initialize(value)
        @value = value
      end

      def eval()
        @value
      end
    end

    class Addition < Node
      attr_accessor :lh, :rh

      def initialize(lh, rh)
        @lh, @rh = lh, rh
      end

      def eval()
        (@lh.is_node? ? @lh.eval : @lh) + (@rh.is_node? ? @rh.eval : @rh)
      end
    end

    class Subtraction < Node
      attr_accessor :lh, :rh

      def initialize(lh, rh)
        @lh, @rh = lh, rh
      end

      def eval()
        (@lh.is_node? ? @lh.eval : @lh) - (@rh.is_node? ? @rh.eval : @rh)
      end
    end

    class Multiplication < Node
      attr_accessor :lh, :rh

      def initialize(lh, rh)
        @lh, @rh = lh, rh
      end

      def eval()
        (@lh.is_node? ? @lh.eval : @lh) * (@rh.is_node? ? @rh.eval : @rh)
      end
    end

    class Division < Node
      attr_accessor :lh, :rh

      def initialize(lh, rh)
        @lh, @rh = lh, rh
      end

      def eval()
        (@lh.is_node? ? @lh.eval : @lh) / (@rh.is_node? ? @rh.eval : @rh)
      end
    end

    class VariableAssignment < Node
      def initialize(name, node)
        @name = name.to_sym
        @node = node
      end

      def eval(scope = @@global_scope)
        scope[@name] = @node.is_node? ? @node.eval : @node
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

