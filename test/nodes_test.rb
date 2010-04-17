require 'test/test_helpers.rb'

class DunderNodesTest < Test::Unit::TestCase

  def setup
    @node = current_node(method_name)
  end
  # 
  # def teardown
  # end
  
  def test_addition    
    # Make sure we made a class and that both right hand and left hand are nil
    assert_instance_of Dunder::Nodes::Addition, @node
    assert_nil @node.lh and @node.rh
    
    # Commence calculations!
    @node.lh, @node.rh = 2, 4
    assert_equal 6, @node.eval
    
    @node.lh, @node.rh = -3, 4
    assert_equal 1, @node.eval
    
    @node.lh, @node.rh = 33, -44
    assert_equal -11, @node.eval
  end
  
  def test_subtraction 
    # Make sure we made a class and that both right hand and left hand are nil
    assert_instance_of Dunder::Nodes::Subtraction, @node
    assert_nil @node.lh and @node.rh
    
    # Commence calculations!
    @node.lh, @node.rh = 8, 2
    assert_equal 6, @node.eval
    
    @node.lh, @node.rh = 3, -4
    assert_equal 7, @node.eval
    
    @node.lh, @node.rh = -33, 5
    assert_equal -38, @node.eval
  end
  
  def test_multiplication
    # Make sure we made a class and that both right hand and left hand are nil
    assert_instance_of Dunder::Nodes::Multiplication, @node
    assert_nil @node.lh and @node.rh
    
    # Commence calculations!
    @node.lh, @node.rh = 8, 2
    assert_equal 16, @node.eval
    
    @node.lh, @node.rh = 3, -4
    assert_equal -12, @node.eval
    
    @node.lh, @node.rh = -33, 0
    assert_equal 0, @node.eval
  end
  
  def test_division
    # Make sure we made a class and that both right hand and left hand are nil
    assert_instance_of Dunder::Nodes::Division, @node
    assert_nil @node.lh and @node.rh
    
    # Commence calculations!
    @node.lh, @node.rh = 8, 2
    assert_equal 4, @node.eval
    
    @node.lh, @node.rh = 10, -2
    assert_equal -5, @node.eval
    
    @node.lh, @node.rh = -33, 1
    assert_equal -33, @node.eval
  end
    
end
