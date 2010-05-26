# coding: utf-8

####
# parser_test.rb
# http://github.com/bjorngylling/TDP019
# Part of the Dunder language project by Björn Gylling and Linus Karlsson
# This file contains test-cases the language

require "test/test_helpers.rb"

require "stringio"

class DunderParserTest < Test::Unit::TestCase

  def setup
    @global_scope = Hash.new
    @d_parser = nil
    @d_parser = Dunder::Parser.new
  end
  
  def test_addition
    assert_equal 6, parse("4+2")
  end
  
  def test_addition_with_strings
    assert_equal "hej då", parse("'hej' + ' då'")
  end

  def test_subtraction
    assert_equal 6, parse("8-2")
  end

  def test_multiplication
    assert_equal 16, parse("8*2")
  end

  def test_division
    assert_equal 4, parse("8/2")
  end
  
  def test_parser_function_remove_unwanted_newlines_in
    string = "Here comes two empty rows with tabs
    
    
and here is the last row"
    expected_result = "Here comes two empty rows with tabs
and here is the last row"
    assert_equal expected_result, @d_parser.remove_unwanted_newlines_in(string)
  end

  def test_whitespace
    assert_equal 6, parse("4 +2")
    assert_equal 6, parse("4	+ 2")
    assert_equal 6, parse("4 +2\n")
    assert_equal 6, parse("#HEEEJ\n\n\n4 +2\n")
  end

  def test_statement_list
    assert_equal 35, parse("1*4;33 + 2")
    assert_equal 6, parse("1*4\n4 + 2")
  end

  def test_math_priority
    assert_equal 7, parse("1+2*3")
    assert_equal -1, parse("1-5+3")
    assert_equal 7, parse("3*2+1")
    assert_equal 8, parse("1+3*2+1")
    assert_equal -1, parse("1-10/2+3")
    assert_equal 48, parse("1+10*10/2-3")
  end

  def test_negativity
    assert_equal 4, parse("1--3")
    assert_equal 10, parse("-2*-5")
    assert_equal 1, parse("-4+5")
    assert_equal -9, parse("-4+-5")
    assert_equal -2.4, parse("-4.5--2.1")
  end

  def test_zero_fill
    assert_equal 12, parse("00001*0001+0000000011")
    assert_equal 12.1, parse("00001*0001+0000000011.10")
  end

  def test_math_with_variables
    code = "var = 100 * 10
            x = 12
            var = var + x"
    assert_equal 1012, parse(code)
  end

  def test_math_with_float
    assert_equal 5.3, parse("10.5 - 5.2")
    assert_equal 5.1, parse("10.2 * 0.5")
    assert_equal 5.1, parse("10.2 * .5")
  end

  def test_boolean
    assert_equal true, parse("true")
    assert_equal false, parse("false")
  end

  def test_comparison
    assert_equal true, parse("10 == 10")
    assert_equal true, parse("10 != 9")
    assert_equal true, parse("'hej' == 'hej'")
    assert_equal true, parse("100 > 99")
    assert_equal true, parse("var = 12;result = var < 42; result")
    assert_equal true, parse("100 >= 100")
    assert_equal true, parse("100.00 == 100")
    assert_equal false, parse("100 > 100")
    assert_equal true, parse("100 >= 99")
    assert_equal true, parse("100 != 'aaa'")
  end

  def test_ifstatement
    assert_equal 102, parse("if(10 == 10) {
                                         100 + 2
                                       }")
    assert_equal nil, parse("if(10 == 10) { 
                                         if(20==19) { 100+15 }
                                       }")
    assert_equal 115, parse("if(10 == 10) { 
                                         if(20==20) { 100+15 }
                                       }")
    assert_equal false, parse("if(10 == 11) {
                                           arne = 20 
                                         }
                                         arne")
  end

  def test_ifelsestatement
    assert_equal 102, parse("if(10 == 10) { 
                               100 + 2
                             } else { 
                               100 - 2 
                             }")
    
    assert_equal 98, parse("if(10 == 11) { 
                              100 + 2 
                            } else { 
                              100 - 2
                            }")
                                      
    assert_equal "hej", parse("if(10 == 11) { 
                                 arne = 20 
                               } else { 
                                 foo = 'hej' 
                               }
                               foo")

    code = "x = 12
            y = 10 + 2
            if(y == x) {
              new_var = x + 32
            } else {
              new_var = y + 30
            }
            new_var"
    assert_equal 44, parse(code)
  end

  def test_whilestatement
    assert_equal 10, parse("x = 1; 
                            while(x < 10) { x = x + 1 }; x")

    code = "x = 1
            answer = 1
            number = 5
            while(x <= number) { #Körs tills x är större än number
              #Multiplicerar det nuvarande numret med gamla faktorn
              answer = answer * x
              x = x + 1
            }
            answer"    
    assert_equal 120, parse(code)

  end

  def test_variable_assignment
    assert_equal "hej", parse("var = 'hej'")
    assert_equal 100, parse("var = 100")
    assert_equal 1000, parse("var = 100 * 10")
    assert_equal 20, parse("x = 19; x = x + 1")
  end
  
  def test_string_with_nonstandard_characters
    assert_equal "heh&&lll", parse('var = "heh&&lll"')
  end

  def test_variable_reading
    assert_equal 5, parse("var = 5")
    assert_equal 5, parse("var")
    assert_equal 200, parse("var = 100 * 2")
    assert_equal 200, parse("var")


    assert_equal 1000, parse("var = 100 * 10; var")
    assert_equal 1000, parse("var = 100 * 10;12 + 2; var")
    assert_equal 1000, parse("var = 100 * 10
                              12 + 2
                              var")
    assert_equal 1000, parse("var = 100 * 10;x = 12; var")
  end
  
  def test_scope
    code = "x = 0
            while(x < 5) {
              x = x + 1
              z = x
            }"
            
    parse(code)
    
    assert_equal false, parse("z") # z should not be set
    assert_equal 5, parse("x")
  end

  def test_comments
    assert_equal 1000, parse("var = 100 * 10
                              12 + 2 # var = 10
                              var")
    assert_equal 1000, parse("var = 100 * 10
                              12 + 2 // var = 10
                              var")
    assert_equal 1000, parse("var = 100 * 10
                              12 + 2 # var = 12
                              /* hejeje */ comment does not end here
                                var = 100
                              dfd*/ var")
  end
  
  def test_function_definition
    assert parse("def foo() { 10 }")
  end
  
  def test_function_without_arguments
    parse("def foo() { 10 }")
    
    assert_equal 10, parse("foo()")
  end

  def test_function_with_arguments
    parse("def foo(x) { x + 10 }")
    
    assert_equal 20, parse("foo(10)")
  end
  
  def test_function_with_multiple_arguments
    parse("def foo(x, y) { x + y }")
    
    assert_equal 15, parse("foo(10, 5)")
  end
  
  def test_function_with_variable_as_argument
    
    parse("def foo(x) { x + 10 }")
    
    assert_equal 40, parse("var = 30; foo(var)")
  end
  
  def test_function_with_return
    parse("def foo(x) { x + 10
             // Ugly formatting to make sure that works too
             return 12
             13 }")
    assert_equal 12, parse("foo(10)")
    
    parse("def foo(x) { 
             x = x + 10
             return x + 5
             13
           }")
    assert_equal 25, parse("foo(10)")
    
    parse("def foo(x) { 
             x = x + 10
             if(x > 2) {
               return x
             }
             13
           }")
    assert_equal 20, parse("foo(10)")
    
    parse("def foo(y) { 
             z = 0
             while(z < 20) {
               if(z == y) {
                 return z * 10
               }
               z = z + 1
             }
             return 42
           }")
    assert_equal 100, parse("foo(10)")
  end
  
  def test_recursive_functions
    code = "def foo(x) { 
              if(x >= 100) { 
                return x 
              } 
              else { 
                return foo(x + 10) 
              }
            }"
    
    parse(code)
    
    assert_equal 100, parse("foo(0)")
    
    code = "def fib(n) {
              if (n <= 1) {
                return n
              } else {
                return fib(n-1)+fib(n-2)
              }
            }"
    parse(code)
    
    assert_equal 8, parse("fib(6)")
  end
  
  def test_lambda_functions
    code = "foo = { |var| var = var + 10 }
            foo(22)"
            
    assert_equal 32, parse(code)
  end
  
  def test_run_code_from_file
    dir = $:.unshift File.dirname(__FILE__)
    result = %x[ruby lib/dunder.rb test/fixtures/factorial.dun]
    assert_equal 120, result.chomp.to_i
  end
  
  def test_print_string    
    code = "x = 0
            while(x < 5) {
              x = x + 1
              print 'Hello world'
            }"
    
    assert_equal ("Hello world\n" * 5), run_output_test(code)
  end
  
  def test_print_number    
    code = "x = 0
            while(x < 4) {
              x = x + 1
              print 100 - 50
            }"
    
    assert_equal ("50\n" * 4), run_output_test(code)
  end
  
  def test_static_binding
    dir = $:.unshift File.dirname(__FILE__)
    result = %x[ruby lib/dunder.rb test/fixtures/static_binding.dun]
    assert_equal 10, result.chomp.to_i
    
    result = %x[ruby lib/dunder.rb test/fixtures/static_binding_with_lambda.dun]
    assert_equal 15, result.chomp.to_i
  end
  
end

