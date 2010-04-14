require 'lib/dunder.rb'

require 'test/unit'

class DunderParserTest < Test::Unit::TestCase
  
  def setup
    @d_parser = Dunder::Parser.new
  end

  def teardown
    @d_parser = nil
  end

  def test_variable_assignment
    assert_equal 12, @d_parser.parse("hej = 12")
  end
  
end
