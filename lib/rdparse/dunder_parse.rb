# Dunder language parser

require "lib/rdparse/rdparse.rb"

module Dunder
  
  class Parser
    
    def initialize
      @dunder_parser = Rdparse::Parser.new("dunder") do
      	# Any word
        token(/[A-Za-z_]+/) {|m| m}
        
        # Float, has to be before integer else we get "int.int"
        token(/\d+\.\d+/) {|m| m.to_f }
        
        # Integer
        token(/\d+/) {|m| m.to_i }
        
        # Remove whitespace
        token(/\s+/)
        
        token(/./) {|m| m }
        
        start :statement_list do 
          match(:statement, :statement_terminator, :statement_list)
          match(:statement, :statement_terminator)
        end
        
        rule :statement_terminator do
          match(';')
          match("\n")
        end
        
        rule :statement do 
          match(:assignment_expression)
          match(:function_call)
          match(:if_statement)
          match(:while_statement)
          match(:function_def)
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
          match('true')
          match('false')
          match(:number)
          match(:string)
          match(:indetifier)
          match(:function_call)
          match(:expression, :binary_operator, :expression)
        end
        
        rule :identifier do
          #match()
        end
        
        rule :number do
          match(:integer)
          match(:float)
        end
        
        rule :integer do
          match(:non_zero_digit, :digits)
          match('0')
        end
        
        rule :non_zero_digit do
          match("1-9")
        end
        
        rule :digits do
          match(:digits, :digit)
          match(:digit)
        end
        
        rule :digit do
          match("0-9")
        end
        
      end
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