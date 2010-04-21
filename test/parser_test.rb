require 'test/test_helpers.rb'

class DunderParserTest < Test::Unit::TestCase

  def setup
    @d_parser = Dunder::Parser.new
  end

  def teardown
    @d_parser = nil
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
  end

  def test_variable_assignment
    assert_equal "hej", @d_parser.parse("var = 'hej'").eval
    assert_equal 100, @d_parser.parse("var = 100").eval
    assert_equal 1000, @d_parser.parse("var = 100 * 10").eval
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

  def test_math_with_variables
    code = "var = 100 * 10;x = 12; var"
    assert_equal 10, @d_parser.parse(code).eval
  end

end

