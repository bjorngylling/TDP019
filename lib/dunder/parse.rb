# Dunder language parser

require "lib/rdparse/rdparse.rb"

module Dunder
  
  class Parser
    
    def initialize
      @dunder_parser = Rdparse::Parser.new("dunder") do
        # Remove whitespace, except newlines since they are statement_terminators
        token(/[ \t]+/)
        
        token(/\w+/) { |t| t }
        
        token(/./) { |t| t }
        
        start :statement_list do
          match(:statement_list, :statement_terminator, :statement) { |a, _, b| a }
          match(:statement, :statement_terminator) { |a, _| a }
          match(:statement) { |a| a }
        end
        
        rule :statement_terminator do
          match(';')
          match("\n")
        end
        
        rule :statement do
          match(:assignment_expression) { |a| a }
          match(:if_statement) { |a| a }
          match(:while_statement) { |a| a }
          match(:function_def) { |a| a }
          match(:expression) { |a| a }
        end
  
        rule :assignment_expression do
          match(:identifier, '=', :expression)
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
          # dirty hack to allow calculations, should return a node instead
          match(:expression, :binary_operator, :expression) { |rh, op, lh| op.lh, op.rh = lh, rh; op }
          match('true') { true }
          match('false') { false }
          match(:string) { |a| a }
          match(:identifier) { |a| a }
          match(:function_call)
          match(:number) { |a| a }
        end
        
        rule :binary_operator do
          match('+') { Dunder::Nodes::Addition.new }
          match('-') { "-" }
          match('*') { "*" }
          match('/') { "/" }
        end
        
        rule :identifier do
          #match()
        end
        
        rule :number do
          match(:integer) { |a| a.to_i }
          match(:float) { |a| a.to_f }
        end
        
        rule :integer do
          match(:digits) { |a| a }
          #match(:non_zero_digit, :digits) { |a, b| a << b; puts "\nintified\n" }
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