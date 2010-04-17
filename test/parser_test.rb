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
    assert_equal 6, @d_parser.parse("1*4\n4 + 2").eval
  end
    
end
