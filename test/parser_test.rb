require "test/test_helpers.rb"

class DunderParserTest < Test::Unit::TestCase

  def setup
    @d_parser = nil
    @d_parser = Dunder::Parser.new
  end
  
  def test_addition
    assert_equal 6, @d_parser.parse("4+2").eval
  end
  
  def test_addition_with_strings
    assert_equal "hej då", @d_parser.parse("'hej' + ' då'").eval
  end

  def test_subtraction
    assert_equal 6, @d_parser.parse("8-2").eval
  end

  def test_multiplication
    assert_equal 16, @d_parser.parse("8*2").eval
  end

  def test_division
    assert_equal 4, @d_parser.parse("8/2").eval
  end
  
  def test_parser_function_remove_unwanted_newlines_in
    string = "Here comes two empty rows with tabs
    
    
and here is the last row"
    expected_result = "Here comes two empty rows with tabs
and here is the last row"
    assert_equal expected_result, @d_parser.remove_unwanted_newlines_in(string)
  end

  def test_whitespace
    assert_equal 6, @d_parser.parse("4 +2").eval
    assert_equal 6, @d_parser.parse("4	+ 2").eval
    assert_equal 6, @d_parser.parse("4 +2\n").eval
    assert_equal 6, @d_parser.parse("#HEEEJ\n\n\n4 +2\n").eval
  end

  def test_statement_list
    assert_equal 35, @d_parser.parse("1*4;33 + 2").eval
    assert_equal 6, @d_parser.parse("1*4\n4 + 2").eval
  end

  def test_math_priority
    assert_equal 7, @d_parser.parse("1+2*3").eval
    assert_equal -1, @d_parser.parse("1-5+3").eval
    assert_equal 7, @d_parser.parse("3*2+1").eval
    assert_equal 8, @d_parser.parse("1+3*2+1").eval
    assert_equal -1, @d_parser.parse("1-10/2+3").eval
    assert_equal 48, @d_parser.parse("1+10*10/2-3").eval
  end

  def test_negativity
    assert_equal 4, @d_parser.parse("1--3").eval
    assert_equal 10, @d_parser.parse("-2*-5").eval
    assert_equal 1, @d_parser.parse("-4+5").eval
    assert_equal -9, @d_parser.parse("-4+-5").eval
    assert_equal -2.4, @d_parser.parse("-4.5--2.1").eval
  end

  def test_zero_fill
    assert_equal 12, @d_parser.parse("00001*0001+0000000011").eval
    assert_equal 12.1, @d_parser.parse("00001*0001+0000000011.10").eval
  end

  def test_math_with_variables
    code = "var = 100 * 10
            x = 12
            var = var + x"
    assert_equal 1012, @d_parser.parse(code).eval
  end

  def test_math_with_float
    assert_equal 5.3, @d_parser.parse("10.5 - 5.2").eval
    assert_equal 5.1, @d_parser.parse("10.2 * 0.5").eval
    assert_equal 5.1, @d_parser.parse("10.2 * .5").eval
  end

  def test_boolean
    assert_equal true, @d_parser.parse("true").eval
    assert_equal false, @d_parser.parse("false").eval
  end

  def test_comparison
    assert_equal true, @d_parser.parse("10 == 10").eval
    assert_equal true, @d_parser.parse("10 != 9").eval
    assert_equal true, @d_parser.parse("'hej' == 'hej'").eval
    assert_equal true, @d_parser.parse("100 > 99").eval
    assert_equal true, @d_parser.parse("var = 12;result = var < 42; result").eval
    assert_equal true, @d_parser.parse("100 >= 100").eval
    assert_equal true, @d_parser.parse("100.00 == 100").eval
    assert_equal false, @d_parser.parse("100 > 100").eval
    assert_equal true, @d_parser.parse("100 >= 99").eval
    assert_equal true, @d_parser.parse("100 != 'aaa'").eval
  end

  def test_ifstatement
    assert_equal 102, @d_parser.parse("if(10 == 10) {
                                         100 + 2
                                       }").eval
    assert_equal nil, @d_parser.parse("if(10 == 10) { 
                                         if(20==19) { 100+15 }
                                       }").eval
    assert_equal 115, @d_parser.parse("if(10 == 10) { 
                                         if(20==20) { 100+15 }
                                       }").eval
    assert_equal false, @d_parser.parse("if(10 == 11) {
                                           arne = 20 
                                         }
                                         arne").eval
  end

  def test_ifelsestatement
    assert_equal 102, @d_parser.parse("if(10 == 10) { 
                                         100 + 2
                                       } else { 
                                         100 - 2 
                                       }").eval
    
    assert_equal 98, @d_parser.parse("if(10 == 11) { 
                                        100 + 2 
                                      } else { 
                                        100 - 2
                                      }").eval
                                      
    assert_equal "hej", @d_parser.parse("if(10 == 11) { 
                                           arne = 20 
                                         } else { 
                                           foo = 'hej' 
                                         }
                                         foo").eval

    code = "x = 12
            y = 10 + 2
            if(y == x) {
              new_var = x + 32
            } else {
              new_var = y + 30
            }
            new_var"
    assert_equal 44, @d_parser.parse(code).eval
  end

  def test_whilestatement
    assert_equal 10, @d_parser.parse("x = 1; 
                                      while(x < 10) { x = x + 1 }; x").eval

    code = "x = 1
            answer = 1
            number = 5
            while(x <= number) { #Körs tills x är större än number
              #Multiplicerar det nuvarande numret med gamla faktorn
              answer = answer * x
              x = x + 1
            }
            answer"    
    assert_equal 120, @d_parser.parse(code).eval

  end

  def test_variable_assignment
    assert_equal "hej", @d_parser.parse("var = 'hej'").eval
    assert_equal 100, @d_parser.parse("var = 100").eval
    assert_equal 1000, @d_parser.parse("var = 100 * 10").eval
    assert_equal 20, @d_parser.parse("x = 19; x = x + 1").eval
  end
  
  def test_string_with_nonstandard_characters
    assert_equal "heh&&lll", @d_parser.parse('var = "heh&&lll"').eval
  end

  def test_variable_reading
    s = Hash.new
    assert_equal 5, @d_parser.parse("var = 5").eval(s)
    assert_equal 5, @d_parser.parse("var").eval(s)
    assert_equal 200, @d_parser.parse("var = 100 * 2").eval(s)
    assert_equal 200, @d_parser.parse("var").eval(s)


    assert_equal 1000, @d_parser.parse("var = 100 * 10; var").eval
    assert_equal 1000, @d_parser.parse("var = 100 * 10;12 + 2; var").eval
    assert_equal 1000, @d_parser.parse("var = 100 * 10
                                        12 + 2
                                        var").eval
    assert_equal 1000, @d_parser.parse("var = 100 * 10;x = 12; var").eval
  end
  
  def test_scope
    s = Hash.new
    
    code = "x = 0
            while(x < 5) {
              x = x + 1
              z = x
            }"
            
    @d_parser.parse(code).eval(s)
    
    assert_equal false, @d_parser.parse("z").eval(s) # z should not be set
    assert_equal 5, @d_parser.parse("x").eval(s)
  end

  def test_comments
    assert_equal 1000, @d_parser.parse("var = 100 * 10
                                        12 + 2 # var = 10
                                        var").eval
    assert_equal 1000, @d_parser.parse("var = 100 * 10
                                        12 + 2 // var = 10
                                        var").eval
    assert_equal 1000, @d_parser.parse("var = 100 * 10
                                        12 + 2 # var = 12
                                        /* hejeje */ comment does not end here
                                          var = 100
                                        dfd*/ var").eval
  end
  
  def test_function_definition
    assert @d_parser.parse("def foo() { 10 }").eval
  end
  
  def test_function_without_arguments
    global_scope = Hash.new
    
    @d_parser.parse("def foo() { 10 }").eval(global_scope)
    
    assert_equal 10, @d_parser.parse("foo()").eval(global_scope)
  end

  def test_function_with_arguments
    global_scope = Hash.new
    
    @d_parser.parse("def foo(x) { x + 10 }").eval(global_scope)
    
    assert_equal 20, @d_parser.parse("foo(10)").eval(global_scope)
  end
  
  def test_function_with_multiple_arguments
    global_scope = Hash.new
    
    @d_parser.parse("def foo(x, y) { x + y }").eval(global_scope)
    
    assert_equal 15, @d_parser.parse("foo(10, 5)").eval(global_scope)
  end
  
  def test_function_with_variable_as_argument
    global_scope = Hash.new
    
    @d_parser.parse("def foo(x) { x + 10 }").eval(global_scope)
    
    assert_equal 40, @d_parser.parse("var = 30; foo(var)").eval(global_scope)
  end
  
  def test_function_with_return
    global_scope = Hash.new
    @d_parser.parse("def foo(x) { x + 10
                     return 12
                     13 }").eval(global_scope)
    
    assert_equal 12, @d_parser.parse("foo(10)").eval(global_scope)
    
    global_scope = Hash.new
    @d_parser.parse("def foo(x) { x = x + 10
                     return x + 5
                     13 }").eval(global_scope)
    
    assert_equal 25, @d_parser.parse("foo(10)").eval(global_scope)
  end
  
  def test_recursive_functions
    global_scope = Hash.new
    
    code = "def foo(x) { 
              if(x >= 100) { 
                return x 
              } 
              else { 
                return foo(x + 10) 
              }
            }"
    
    @d_parser.parse(code).eval(global_scope)
    
    assert_equal 100, @d_parser.parse("foo(0)").eval(global_scope)
    
    code = "def fib(n) {
              if (n <= 1) {
                return n
              } else {
                return fib(n-1)+fib(n-2)
              }
            }"
    @d_parser.parse(code).eval(global_scope)
    
    assert_equal 8, @d_parser.parse("fib(6)").eval(global_scope)
  end
  
  def test_run_code_from_file
    result = %x[ruby lib/dunder.rb test/fixtures/factorial.dun]
    assert_equal 120, result.chomp.to_i
  end
  
  def test_print_string
    require 'stringio'

    # Redirect stdout to output
    output = StringIO.new
    old_stdout, $stdout = $stdout, output
    
    code = "x = 0
            while(x < 5) {
              x = x + 1
              print 'Hello world'
            }"
            
    @d_parser.parse(code).eval
    
    # Restore stdout
    $stdout = old_stdout
    
    assert_equal ("Hello world\n" * 5), output.string
  end
  
  def test_print_number
    require 'stringio'

    # Redirect stdout to output
    output = StringIO.new
    old_stdout, $stdout = $stdout, output
    
    code = "x = 0
            while(x < 4) {
              x = x + 1
              print 100 - 50
            }"
            
    @d_parser.parse(code).eval
    
    # Restore stdout
    $stdout = old_stdout
    
    assert_equal ("50\n" * 4), output.string
  end
  
end

