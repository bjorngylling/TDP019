require "test/test_helpers.rb"

class DunderParserTest < Test::Unit::TestCase

  def setup
    @d_parser = nil
    @d_parser = Dunder::Parser.new
  end

  def test_addition
    assert_equal 6, @d_parser.parse("4+2").eval
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

  def test_whitespace
    assert_equal 6, @d_parser.parse("4 +2").eval
    assert_equal 6, @d_parser.parse("4	+ 2").eval
    assert_equal 6, @d_parser.parse("4 +2\n").eval
    assert_equal 6, @d_parser.parse("\n\n\n\n\n4 +2\n").eval
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
    assert_equal 102, @d_parser.parse("if(10 == 10) { 100 + 2 }").eval
    assert_equal nil, @d_parser.parse("if(10 == 10) { if(20==19){100+15} }").eval
    assert_equal 115, @d_parser.parse("if(10 == 10) { if(20==20){100+15} }").eval
    assert_equal false, @d_parser.parse("if(10 == 11) { arne = 20 }; arne").eval
  end

  def test_ifelsestatement
    assert_equal 102, @d_parser.parse("if(10 == 10) { 100 + 2 } else { 100 - 2 }").eval
    assert_equal 98, @d_parser.parse("if(10 == 11) { 100 + 2 } else { 100 - 2 }").eval
    assert_equal "hej", @d_parser.parse("if(10 == 11) { arne = 20 } else { foo = 'hej' }; foo").eval

    code = "x = 12
            y = 10 + 2
            if(y == x) {
              new_var = x + 32
            } else {
              new_var = y + 30
            }
            new_var"
    #assert_equal 44, @d_parser.parse(code).eval # Doesnt work because of new-linefails
  end

  def test_whilestatement
    assert_equal 10, @d_parser.parse("x = 1; while(x < 10) { x = x + 1 }; x").eval
  end

  def test_variable_assignment
    assert_equal "hej", @d_parser.parse("var = 'hej'").eval
    assert_equal 100, @d_parser.parse("var = 100").eval
    assert_equal 1000, @d_parser.parse("var = 100 * 10").eval
    assert_equal 20, @d_parser.parse("x = 19; x = x + 1").eval
  end

  def test_variable_reading
    assert_equal 5, @d_parser.parse("var = 5").eval
    assert_equal 5, @d_parser.parse("var").eval
    assert_equal 200, @d_parser.parse("var = 100 * 2").eval
    assert_equal 200, @d_parser.parse("var").eval

    @d_parser.parse("var = 0").eval # reset variable

    assert_equal 1000, @d_parser.parse("var = 100 * 10; var").eval
    assert_equal 1000, @d_parser.parse("var = 100 * 10;12 + 2; var").eval
    assert_equal 1000, @d_parser.parse("var = 100 * 10
                                        12 + 2
                                        var").eval
    assert_equal 1000, @d_parser.parse("var = 100 * 10;x = 12; var").eval
  end

  def test_comments
    assert_equal 1000, @d_parser.parse("var = 100 * 10
                                        12 + 2 # var = 10
                                        var").eval
    assert_equal 1000, @d_parser.parse("var = 100 * 10
                                        12 + 2 # var = 12
                                        /* hejeje
                                          var = 100
                                        dfd*/ var").eval
  end


end

