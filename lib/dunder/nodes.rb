# coding: utf-8

####
# nodes.rb
# http://github.com/bjorngylling/TDP019
# Part of the Dunder language project by Björn Gylling and Linus Karlsson
# This file contains all the nodes used to build the parse-tree and
# evaluate it.

module Dunder
  module Nodes
    @return = nil

    class Node
      include Dunder::Helpers

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

      def eval(scope)
        result = nil
        @statement_list.each do |statement|
          
          result = statement.eval(scope)
          
          if statement.kind_of? Dunder::Nodes::ReturnStatement
            result = statement
            break
          end
          if result.kind_of? Dunder::Nodes::ReturnStatement
            break
          end
          
        end

        return result
      end
    end

    class DString < Node
      def initialize(value)
        @value = value
      end

      def eval(scope)
        @value
      end
    end

    class DInteger < Node
      def initialize(value)
        @value = value.to_i
      end

      def eval(scope)
        @value
      end

      def negative
        self.class.new -@value
      end
    end

    class DFloat < Node
      def initialize(value)
        @value = value.to_f
      end

      def eval(scope)
        @value
      end

      def negative
        self.class.new -@value
      end
    end

    class DBoolean < Node
      def initialize(value)
        if value == nil || value == 0 || value == false
          @value = false
        else
          @value = true
        end
      end

      def eval(scope = Hash.new)
        @value
      end
    end

    class Addition < Node
      def initialize(lh, rh)
        @lh, @rh = lh, rh
      end

      def eval(scope)
        @lh.eval(scope) + @rh.eval(scope)
      end
    end

    class Subtraction < Node
      def initialize(lh, rh)
        @lh, @rh = lh, rh
      end

      def eval(scope)
        @lh.eval(scope) - @rh.eval(scope)
      end
    end

    class Multiplication < Node
      def initialize(lh, rh)
        @lh, @rh = lh, rh
      end

      def eval(scope)
        @lh.eval(scope) * @rh.eval(scope)
      end
    end

    class Division < Node
      def initialize(lh, rh)
        @lh, @rh = lh, rh
      end

      def eval(scope)
        @lh.eval(scope) / @rh.eval(scope)
      end
    end

    class Comparison < Node
      def initialize(lh, op, rh)
        @lh, @rh, @op = lh, rh, op
      end

      def eval(scope)
        lh = @lh.eval(scope)
        rh = @rh.eval(scope)

        lh = "'#{lh}'" if lh.kind_of? String
        rh = "'#{rh}'" if rh.kind_of? String

        Kernel.eval("#{lh} #{@op} #{rh}")
      end
    end

    class IfStatement < Node
      def initialize(condition, stmt_list, else_stmt_list = nil)
        @condition = condition
        @stmt_list = stmt_list
        @else_stmt_list = else_stmt_list
      end

      def eval(scope)
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

      def eval(scope)
        while_scope = {"PARENTSCOPE" => scope}
        result = nil
        while @condition.eval(while_scope) and result.class != ReturnStatement do
          result = @stmt_list.eval(while_scope)
        end
        
        result
      end
    end

    class VariableAssignment < Node
      def initialize(name, node)
        @name = name.to_sym
        @node = node
      end

      def eval(scope)
        value = @node.eval(scope)

        assign(scope, @name, value)

        return value
      end

    end

    class Variable < Node
      def initialize(name)
        @name = name.to_sym
      end

      def eval(scope)
        return look_up(@name, scope)
      end
    end
    
    class PrintStatement < Node
      def initialize(expression)
        @string = expression
      end

      def eval(scope)
        puts @string.eval(scope)
      end
    end

    class ReturnStatement < Node
      attr_reader :value
      
      def initialize(expression)
        @expression = expression
      end

      def eval(scope)
        @value = @expression.eval(scope)
      end
    end

    class FunctionDefinition < Node
      attr_reader :params, :stmt_list, :scope

      def initialize(name, params, stmt_list)
        if name
          @name = name.to_sym
        else
          @name = nil
        end
        
        @params = params.map { |param| param.to_sym }
        @stmt_list = stmt_list
      end

      def eval(scope)
        @scope = scope
        if @name
          assign(scope, @name, self)
        end

        return self
      end

    end

    class FunctionCall < Node

      def initialize(name, args)
        @name = name.to_sym
        @arguments = args
      end

      def eval(scope)
        # Find function definition in scopes
        function_definition = look_up(@name, scope)
        
        params = function_definition.params
        
        if params.length != @arguments.length
          return "Function #{@name.to_s} called with invalid number of \
arguments. (#{@arguments.length} for #{params.length})"
        end
        
        # Give our parameters value from the argument-array and create 
        # a scope from that.
        evaluated_arguments = @arguments.map { |a| a.eval(scope) }
        function_scope = build_frame(params, evaluated_arguments)
        function_scope["OUTSIDE_FUNCTION_DEF"] = function_definition.scope
        
        result = nil

        function_definition.stmt_list.each do |statement|
          
          result = statement.eval(function_scope)
          
          if statement.kind_of? Dunder::Nodes::ReturnStatement
            result = statement.value
            break
          elsif result.kind_of? Dunder::Nodes::ReturnStatement
            result = result.value
            break
          end
          
        end

        result
      end

    end

  end
end

