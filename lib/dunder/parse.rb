# Dunder language parser

require "lib/rdparse/rdparse.rb"

module Dunder

  class Parser

    def initialize
      @dunder_parser = Rdparse::Parser.new("dunder") do
        # Remove whitespace, except newlines since they are statement_terminators
        token(/[ \t]+/)

        token(/[\n;]/) { |t| t }

        token(/\w+/) { |t| t }

        token(/./) { |t| t }

        start :statement_list do
          match(:statement, :statement_terminator, :statement_list) { |a, _, b| b }
          match(:statement, :statement_terminator) { |a, _| a }
          match(:statement) { |a| a }
        end

        rule :statement_terminator do
          match(";")
          match("\n")
        end

        rule :statement do
          match(:assignment_expression) { |a| a }
          match(:if_statement) { |a| a }
          match(:while_statement) { |a| a }
          match(:function_def) { |a| a }
          match(:expression) { |a| a }
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
          match(:a_expr) { |a| a }
          match('true') { true }
          match('false') { false }
          match(:string) { |a| a }
          match(:identifier) do |name|
            Dunder::Nodes::Variable.new name
          end
          match(:function_call)
          match(:number) { |a| a }
        end

        rule :a_expr do
          match(:a_expr, "+", :m_expr) do | lh, _, rh |
            op = Dunder::Nodes::Addition.new
            op.lh, op.rh = lh, rh
            op
          end
          match(:a_expr, "-", :m_expr) do | lh, _, rh |
            op = Dunder::Nodes::Subtraction.new
            op.lh, op.rh = lh, rh
            op
          end
          match(:m_expr) { |a| a }
        end

        rule :m_expr do
          match(:m_expr, "*", :u_expr) do | lh, _, rh |
            op = Dunder::Nodes::Multiplication.new
            op.lh, op.rh = lh, rh
            op
          end
          match(:m_expr, "/", :u_expr) do | lh, _, rh |
            op = Dunder::Nodes::Division.new
            op.lh, op.rh = lh, rh
            op
          end
          match(:u_expr) { |a| a }
        end

        rule :u_expr do
          match("+", :number) { |a| a }
          match("-", :number) { |a| -a }
          match(:number) { |a| a }
        end

        rule :assignment_expression do
          match(:identifier, '=', :expression) do |identifier, _, value|
            Dunder::Nodes::VariableAssignment.new identifier, value
          end
        end

        rule :identifier do
          match(/[a-z][A-Za-z0-9_]*/) { |a| a }
          match(/_[A-Za-z0-9_]+/) { |a| a }
        end

        rule :number do
          match(:integer) { |a| a.to_i }
          match(:float) { |a| a.to_f }
        end

        rule :integer do
          match(:digits) { |a| a }
        end

        rule :non_zero_digit do
          match(/[1-9]/) { |a| a }
        end

        rule :digits do
          match(:digits, :digit) { |a, b| a << b }
          match(:digit) { |a| a }
        end

        rule :digit do
          match(/[0-9]/) { |a| a }
        end

        rule :lowercase do
          match(/[a-z]+/) { |a| a }
        end

        rule :string do
          match("'", /[^']/, "'") { |_, a, _| a }
          match('"', /[^"]/, '"') { |_, a, _| a }
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

