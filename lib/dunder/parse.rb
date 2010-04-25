# Dunder language parser

require "lib/rdparse/rdparse.rb"

module Dunder

  class Parser

    def initialize
      @dunder_parser = Rdparse::Parser.new("dunder") do
        # Remove whitespace, except newlines since they are statement_terminators
        token(/[ \t]+/)
        
        # Remove all comments
        token(/#.*$/)
        token(/\/\*(\n|.)*\*\//)

        # Remove empty lines
        token(/^\n$/)

        token(/[\n;]/) { |t| t }

        token(/\w+/) { |t| t }

        token(/==|<=|>=|!=/) { |t| t }

        token(/./) { |t| t }

        start :statement_list do
          match(:statement, :statement_terminator, :statement_list) { |a, _, b| b = a + b }
          match(:statement, :statement_terminator)
          match(:statement)
        end

        rule :statement_terminator do
          match("\n")
          match(";")
        end

        rule :statement do
          match(:compound_statement) { |a| Dunder::Nodes::StatementList.new a }
          match(:expression) { |a| Dunder::Nodes::StatementList.new a }
        end

        rule :compound_statement do
          match(:if_statement)
          match(:while_statement)
          match(:function_def)
        end

        rule :if_statement do
          match("if", "(", :expression, ")", /\n?\{/, :statement_list, /\}\n?/,
                "else", /\n?\{/, :statement_list, /\}\n?/) do
                  |_, _, condition, _, _, stmt_list, _, _, _, else_stmt_list, _|
                  Dunder::Nodes::IfStatement.new condition, stmt_list, else_stmt_list
          end
          match("if", "(", :expression, ")", /\n?\{/, :statement_list, /\}\n?/) do |_, _, condition, _, _, stmt_list, _|
            Dunder::Nodes::IfStatement.new condition, stmt_list
          end
        end

        rule :while_statement do
          match("while", "(", :expression, ")", /\n?\{/, :statement_list, "}") do
            |_, _, condition, _, _, stmt_list, _|
            Dunder::Nodes::WhileStatement.new condition, stmt_list
          end
        end

        rule :function_call do
          match(:identifier, :arguments)
        end

        rule :arguments do
          match('(', :expression_list, ')')
        end

        rule :expression_list do
          match(:expression_list, ',', :expression)
          match(:expression)
        end

        rule :expression do
          match(:assignment_expression) { |a| Dunder::Nodes::StatementList.new a }
          match(:comparison)
        end

        rule :comparison do
          match(:a_expr, :comp_operator, :a_expr) do |lh, op, rh|
            Dunder::Nodes::Comparison.new lh, op, rh
          end
          match(:a_expr)
        end

        rule :a_expr do
          match(:a_expr, "+", :m_expr) do | lh, _, rh |
            Dunder::Nodes::Addition.new lh, rh
          end
          match(:a_expr, "-", :m_expr) do | lh, _, rh |
            op = Dunder::Nodes::Subtraction.new lh, rh
          end
          match(:m_expr)
        end

        rule :m_expr do
          match(:m_expr, "*", :u_expr) do | lh, _, rh |
            Dunder::Nodes::Multiplication.new lh, rh
          end
          match(:m_expr, "/", :u_expr) do | lh, _, rh |
            Dunder::Nodes::Division.new lh, rh
          end
          match(:u_expr) { |a| a }
        end

        rule :u_expr do
          match("+", :primary)
          match("-", :primary) { |_, a| a.negative! }
          match(:primary)
        end

        rule :primary do
          match(:boolean)
          match(:number)
          match(:string)
          match(:identifier) do |name|
            Dunder::Nodes::Variable.new name
          end
          match(:function_call)
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
            Dunder::Nodes::VariableAssignment.new identifier, value
          end
        end

        rule :identifier do
          match(/[a-z][A-Za-z0-9_]*/)
          match(/_[A-Za-z0-9_]+/)
        end

        rule :boolean do
          match('true') { Dunder::Nodes::DBoolean.new true }
          match('false') { Dunder::Nodes::DBoolean.new false }
        end

        rule :number do
          match(:float)
          match(:integer)
        end

        rule :integer do
          match(:digits) { |a| Dunder::Nodes::DInteger.new a }
        end

        rule :float do
          match(:digits, ".", :digits) { |a, _, b | Dunder::Nodes::DFloat.new a << "." << b }
        end

        rule :non_zero_digit do
          match(/[1-9]/)
        end

        rule :digits do
          match(:digits, :digit) { |a, b| a << b }
          match(:digit)
        end

        rule :digit do
          match(/[0-9]/)
        end

        rule :lowercase do
          match(/[a-z]+/)
        end

        rule :string do
          match("'", /[^']/, "'") { |_, a, _| Dunder::Nodes::DString.new a }
          match('"', /[^"]/, '"') { |_, a, _| Dunder::Nodes::DString.new a }
        end

      end

      log false
    end

    def parse(code)
      @dunder_parser.parse(code)
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

