require 'test/test_helpers.rb'

##
# The following tests are set up so that the last word in the test name will be
# used as the name of the Node that @node will be. So in a test named
# test_addition, @node.class will be Dunder::Nodes::Addition.
# It also works for more descriptive testnames as long as the last word
# is the Node-name. Ex test_a_very_complicated_ifstatement would @node.class be
# Dunder::Nodes::IfStatement

class DunderNodesTest < Test::Unit::TestCase

  def setup
    @node = create_node(method_name)
  end

  # def teardown
  # end
  
  def test_addition    
    # Make sure we have correct class and that both right hand and left hand are nil
    assert_instance_of Dunder::Nodes::Addition, @node
    assert_nil @node.lh and @node.rh
    
    # Run calculationtests
    @node.lh, @node.rh = 2, 4
    assert_equal 6, @node.eval

    @node.lh, @node.rh = -3, 4
    assert_equal 1, @node.eval

    @node.lh, @node.rh = 33, -44
    assert_equal -11, @node.eval
  end
  
  def test_subtraction
    assert_instance_of Dunder::Nodes::Subtraction, @node
    assert_nil @node.lh and @node.rh
    
    @node.lh, @node.rh = 8, 2
    assert_equal 6, @node.eval

    @node.lh, @node.rh = 3, -4
    assert_equal 7, @node.eval

    @node.lh, @node.rh = -33, 5
    assert_equal -38, @node.eval
  end

  def test_multiplication
    assert_instance_of Dunder::Nodes::Multiplication, @node
    assert_nil @node.lh and @node.rh
    
    @node.lh, @node.rh = 8, 2
    assert_equal 16, @node.eval

    @node.lh, @node.rh = 3, -4
    assert_equal -12, @node.eval

    @node.lh, @node.rh = -33, 0
    assert_equal 0, @node.eval
  end

  def test_division
    assert_instance_of Dunder::Nodes::Division, @node
    assert_nil @node.lh and @node.rh
    
    @node.lh, @node.rh = 8, 2
    assert_equal 4, @node.eval

    @node.lh, @node.rh = 10, -2
    assert_equal -5, @node.eval

    @node.lh, @node.rh = -33, 1
    assert_equal -33, @node.eval
  end
  
  def test_advanced_addition
    assert_instance_of Dunder::Nodes::Addition, @node
    assert_nil @node.lh and @node.rh
    
    # Create another Addition Node and use it as the left hand
    sub_addition = create_node "addition"
    sub_addition.lh, sub_addition.rh = 5, 3
    @node.lh, @node.rh = sub_addition, 10
    assert_equal 18, @node.eval
  end

  def test_variable
    scope = {:var => 12}

    @node.name = "var"
    assert_equal 12, @node.eval(scope)
  end
  
end

