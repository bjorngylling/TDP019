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
        @statement_list = [statement]
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

    class DString < Node
      def initialize(value)
        @value = value
      end

      def eval()
        @value
      end
    end

    class DInteger < Node
      def initialize(value)
        @value = value.to_i
      end

      def eval()
        @value
      end

      def negative!
        @value = -@value
      end
    end

    class DFloat < Node
      def initialize(value)
        @value = value.to_f
      end

      def eval()
        @value
      end

      def negative!
        @value = -@value
      end
    end

    class DBoolean < Node
      def initialize(value)
        @value = value
      end

      def eval()
        @value
      end
    end

    class Addition < Node
      def initialize(lh, rh)
        @lh, @rh = lh, rh
      end

      def eval()
        (@lh.is_node? ? @lh.eval : @lh) + (@rh.is_node? ? @rh.eval : @rh)
      end
    end

    class Subtraction < Node
      def initialize(lh, rh)
        @lh, @rh = lh, rh
      end

      def eval()
        (@lh.is_node? ? @lh.eval : @lh) - (@rh.is_node? ? @rh.eval : @rh)
      end
    end

    class Multiplication < Node
      def initialize(lh, rh)
        @lh, @rh = lh, rh
      end

      def eval()
        (@lh.is_node? ? @lh.eval : @lh) * (@rh.is_node? ? @rh.eval : @rh)
      end
    end

    class Division < Node
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
        value = @node.is_node? ? @node.eval : @node
        
        scope[@name] = value unless assign(scope, value)

        return value
      end

      def assign(scope, value)
        if scope.has_key? @name
          scope[@name] = @node.is_node? ? @node.eval : @node
          return true
        elsif scope.has_key? "PARENTSCOPE"
          return assign(scope["PARENTSCOPE"], value)
        else
          return false
        end
      end

    end

    class Variable < Node
      attr_accessor :name, :scope

      def initialize(name)
        @name = name.to_sym
      end

      def eval(scope = @@global_scope)
        if scope.include?(@name)
          return scope[@name]
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

