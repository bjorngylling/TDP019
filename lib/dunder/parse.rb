# coding: utf-8

# Dunder language parser

require "lib/rdparse/rdparse.rb"

module Dunder

  class Parser
    include Dunder::Nodes

    def initialize
      @dunder_parser = Rdparse::Parser.new("dunder") do
        extend Dunder::Nodes
        
        # Strings
        token(/'[^']*'/) { |t| DString.new t.delete("'") }
        token(/"[^"]*"/) { |t| DString.new t.delete('"') }
        
        # Remove whitespace, except newlines since 
        # they are statement_terminators
        token(/[ \t]+/)

        # Statment terminators
        token(/[\r\n;]/) { |t| t }

        token(/\w+|==|<=|>=|!=|\+|-|\*|<|>|\/|=|\{|\}|\(|\)|\.|,/) { |t| t }

        start :statement_list do
          match(:statement, :statement_terminator, :statement_list) do 
            |a, _, b|
            b = a + b
          end
          match(:statement, :statement_terminator)
          match(:statement)
        end

        rule :statement_terminator do
          match("\n")
          match(";")
        end

        rule :statement do
          match(:return_statement) { |a| StatementList.new a }
          match(:print_statement) { |a| StatementList.new a }
          match(:compound_statement) { |a| StatementList.new a }
          match(:expression) { |a| StatementList.new a }
        end
        
        rule :return_statement do
          match("return", :expression) do |_, expression|
            ReturnStatement.new expression 
          end
        end
        
        rule :print_statement do
          match("print", :expression) do |_, string|
            PrintStatement.new string 
          end
        end

        rule :compound_statement do
          match(:if_statement)
          match(:while_statement)
          match(:function_def)
        end
        
        rule :block_start do
          match('{')
        end
        
        rule :block_end do
          match('}')
        end

        rule :if_statement do
          match("if", "(", :expression, ")", :block_start, 
                  :statement_list,
                :block_end,
                "else", :block_start, 
                  :statement_list, 
                :block_end) do
            |_, _, condition, _, _, stmt_list, _, _, _, else_stmt_list, _|
            IfStatement.new condition, stmt_list, else_stmt_list
          end
          match("if", "(", :expression, ")", :block_start, 
                  :statement_list, 
                :block_end) do |_, _, condition, _, _, stmt_list, _|
            IfStatement.new condition, stmt_list
          end
        end

        rule :while_statement do
          match("while", "(", :expression, ")", :block_start, 
                  :statement_list, :block_end) do
            |_, _, condition, _, _, stmt_list, _|
            WhileStatement.new condition, stmt_list
          end
        end
        
        rule :function_def do
          match("def", :identifier, :parameters, :block_start, 
                  :statement_list, :block_end) do
            |_, name, parameters, _, stmt_list, _|
            FunctionDefinition.new name, parameters, stmt_list.list
          end
        end
        
        rule :parameters do
          match('(', :parameter_list, ')') { |_, list, _| list}
          match('(', ')') { |_, _| [] }
        end
        
        rule :parameter_list do
          match(:identifier, ",", :parameter_list) do
            |identifier, _, params|
            params + [identifier]
          end
          match(:identifier) { |identifier| [identifier] }
        end

        rule :function_call do
          match(:identifier, :arguments) do |name, args|
            Dunder::Nodes::FunctionCall.new name, args
          end
        end

        rule :arguments do
          match('(', :expression_list, ')') { |_, list, _| list }
          match('(', ')') { |_, _| [] }
        end

        rule :expression_list do
          match(:expression, ',', :expression_list) do
            |expression, _, list|
            list + [expression]
          end
          match(:expression) { |expression| [expression] }
        end

        rule :expression do
          match(:assignment_expression)
          match(:comparison)
        end

        rule :comparison do
          match(:a_expr, :comp_operator, :a_expr) do |lh, op, rh|
            Comparison.new lh, op, rh
          end
          match(:a_expr)
        end

        rule :a_expr do
          match(:a_expr, "+", :m_expr) do | lh, _, rh |
            Addition.new lh, rh
          end
          match(:a_expr, "-", :m_expr) do | lh, _, rh |
            Subtraction.new lh, rh
          end
          match(:m_expr)
        end

        rule :m_expr do
          match(:m_expr, "*", :u_expr) do | lh, _, rh |
            Multiplication.new lh, rh
          end
          match(:m_expr, "/", :u_expr) do | lh, _, rh |
            Division.new lh, rh
          end
          match(:u_expr) { |a| a }
        end

        rule :u_expr do
          match("+", :primary)
          match("-", :primary) { |_, a| a.negative }
          match(:primary)
        end

        rule :primary do
          match(:function_call)
          match(:boolean)
          match(:number)
          match(:string)
          match(:identifier) do |name|
            Variable.new name
          end
        end

        rule :comp_operator do
          match('==')
          match('<=')
          match('>=')
          match('>')
          match('<')
          match('!=')
        end

        rule :assignment_expression do
          match(:identifier, '=', :expression) do |identifier, _, value|
            VariableAssignment.new identifier, value
          end
        end

        rule :identifier do
          match(/[a-z][A-Za-z0-9_]*/)
          match(/_[A-Za-z0-9_]+/)
        end

        rule :boolean do
          match('true') { DBoolean.new true }
          match('false') { DBoolean.new false }
        end

        rule :number do
          match(:float)
          match(:integer)
        end

        rule :integer do
          match(:digits) { |a| DInteger.new a }
        end

        rule :float do
          match(:digits, ".", :digits) { |a, _, b | DFloat.new a << "." << b }
          match(".", :digits) { |_, b | DFloat.new "0" << "." << b }
        end

        rule :digits do
          match(:digits, :digit) { |a, b| a << b }
          match(:digit)
        end

        rule :digit do
          match(/[0-9]/)
        end

        rule :string do
          match(DString)
        end

      end

      log false
    end

    def parse(code)
      code = remove_comments_in(code)
      code = remove_unwanted_newlines_in(code)
      
      @dunder_parser.parse(code)
    end
    
    def interactive_parser
      global_scope = Hash.new
      code = ""
      nested_blocks = 0 
      
      puts "Dunder interactive parser. Type exit to quit."
      while(true)  
        print "Dunder> "
        line = STDIN.gets
        break if line.chomp == "exit"
        
        code += line
        
        # Check if the line includes {, then there's more coming
        # so don't parse the code yet.
        if line.include? "{"
          nested_blocks += 1
          next
        end
        
        if line.include? "}"
          nested_blocks -= 1
        end
        
        if nested_blocks == 0
          result = parse(code).eval(global_scope)
          print "=> "
          puts result
          code = ""
        end
      end
    end
    
    def remove_comments_in(code)
      code = code.gsub /#.*$/, ""
      code = code.gsub /\/\/.*$/, ""
      code = code.gsub /\/\*(\n|.)*\*\//, ""
    end
    
    def remove_unwanted_newlines_in(string)
      string.gsub! /;[ |\t]*\n/, "\n"
      string.gsub! /^[ |\t]*\n/, ""
      string.gsub! /\{[ |\t]*\n/, "{"
      string.gsub /\}[ |\t]*\n[ |\t]*else/, "} else"
    end

    def log(state = true)
      if state
        @dunder_parser.logger.level = Logger::DEBUG
      else
        @dunder_parser.logger.level = Logger::WARN
      end
    end
  end

end

