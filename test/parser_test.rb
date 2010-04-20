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
    assert_instance_of Dunder::Nodes::Addition, @d_parser.parse("1*4;33 + 2")
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

end

