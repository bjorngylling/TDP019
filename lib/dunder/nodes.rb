module Dunder
  module Nodes

    class Node

      def is_node?
        true
      end

      def global_scope
        @global_scope ||= Hash.new
#        puts "HEEEEEEEEEEEEEJ: #{@global_scope.class}"
        @global_scope
      end

    end

    class StatementList < Node
      def initialize(statement)
        if statement.kind_of? Array
          @statement_list = statement
        else
          @statement_list = [statement]
        end
      end

      def +(statement_list)
        self.class.new @statement_list + statement_list.list
      end

      def list
        @statement_list
      end

      def eval(scope = global_scope)
        result = nil
        @statement_list.each do |stmt|
          result = stmt.eval(scope)
        end

        return result
      end
    end

    class DString < Node
      def initialize(value)
        @value = value
      end

      def eval(scope = global_scope)
        @value
      end
    end

    class DInteger < Node
      def initialize(value)
        @value = value.to_i
      end

      def eval(scope = global_scope)
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

      def eval(scope = global_scope)
        @value
      end

      def negative!
        @value = -@value
      end
    end

    class DBoolean < Node
      def initialize(value)
        value = value.eval if value.is_node?

        if value == nil || value == 0 || value == false
          @value = false
        else
          @value = true
        end
      end

      def eval(scope = global_scope)
        @value
      end
    end

    class Addition < Node
      def initialize(lh, rh)
        @lh, @rh = lh, rh
      end

      def eval(scope = global_scope)
        (@lh.is_node? ? @lh.eval(scope) : @lh) + (@rh.is_node? ? @rh.eval(scope) : @rh)
      end
    end

    class Subtraction < Node
      def initialize(lh, rh)
        @lh, @rh = lh, rh
      end

      def eval(scope = global_scope)
        (@lh.is_node? ? @lh.eval(scope) : @lh) - (@rh.is_node? ? @rh.eval(scope) : @rh)
      end
    end

    class Multiplication < Node
      def initialize(lh, rh)
        @lh, @rh = lh, rh
      end

      def eval(scope = global_scope)
        (@lh.is_node? ? @lh.eval(scope) : @lh) * (@rh.is_node? ? @rh.eval(scope) : @rh)
      end
    end

    class Division < Node
      def initialize(lh, rh)
        @lh, @rh = lh, rh
      end

      def eval(scope = global_scope)
        (@lh.is_node? ? @lh.eval(scope) : @lh) / (@rh.is_node? ? @rh.eval(scope) : @rh)
      end
    end

    class Comparison < Node
      def initialize(lh, op, rh)
        @lh, @rh, @op = lh, rh, op
      end

      def eval(scope = global_scope)
        lh = @lh.eval(scope) || @lh
        rh = @rh.eval(scope) || @rh

        lh = "'#{lh}'" if lh.kind_of? String
        rh = "'#{rh}'" if rh.kind_of? String

        Kernel.eval("#{lh} #{@op} #{rh}")
      end
    end

    class IfStatement < Node
      def initialize(condition, stmt_list, else_stmt_list = nil)
        @condition, @stmt_list, @else_stmt_list = condition, stmt_list, else_stmt_list
      end

      def eval(scope = global_scope)
        if @condition.eval(scope)
          @stmt_list.eval(scope)
        elsif @else_stmt_list
          @else_stmt_list.eval(scope)
        end
      end
    end

    class WhileStatement < Node
      def initialize(condition, stmt_list)
        @condition, @stmt_list = condition, stmt_list
      end

      def eval(scope = global_scope)
        while @condition.eval(scope) do
          @stmt_list.eval(scope)
        end
      end
    end

    class VariableAssignment < Node
      def initialize(name, node)
        @name = name.to_sym
        @node = node
      end

      def eval(scope = global_scope)
        value = @node.is_node? ? @node.eval(scope) : @node

        scope[@name] = value unless Dunder::Helpers::assign(scope, @name, value)

        return value
      end

    end

    class Variable < Node
      attr_accessor :name, :scope

      def initialize(name)
        @name = name.to_sym
      end

      def eval(scope = global_scope)
        return Dunder::Helpers::look_up(@name, scope)
      end
    end

    class ReturnExpression < Node
      def initialize(expression)
        @expression = expression
      end

      def eval(scope = global_scope)
        @expression.eval(scope)
      end
    end

    class FunctionDefinition < Node
      attr_reader :params, :stmt_list

      def initialize(name, params, stmt_list)
        @name = name.to_sym
        @params = params
        @stmt_list = stmt_list
      end

      def eval(scope = global_scope)
        scope[@name] = self unless Dunder::Helpers::assign(scope, @name, self)

        return self
      end

    end

    class FunctionCall < Node

      def initialize(name, args)
        @name = name.to_sym
        @arguments = args
      end

      def eval(scope = global_scope)
        # Find function definition in scopes
        function_definition = Dunder::Helpers::look_up(@name, scope)

        params = function_definition.params

        function_scope = Hash[*params.zip(@arguments).flatten]
        function_scope["PARENTSCOPE"] = scope

        result = nil

        function_definition.stmt_list.each do |statement|
          if statement.kind_of? Dunder::Nodes::ReturnExpression
            result = statement.eval(scope)
            break
          end

          result = statement.eval(scope)
        end

        result
      end

    end

  end
end

