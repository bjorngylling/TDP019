require "test/test_helpers.rb"

class DunderNodesTest < Test::Unit::TestCase
  
  def setup
    @int_10 = create_node "dinteger", "10"
    @int_5 = create_node "dinteger", "5"
  end
  
  def test_addition
    assert_equal 15, create_node(method_name, @int_10, @int_5).eval
  end
  
  def test_subtraction
    assert_equal 5, create_node(method_name, @int_10, @int_5).eval
  end

  def test_multiplication
    assert_equal 50, create_node(method_name, @int_10, @int_5).eval
  end

  def test_division
    assert_equal 2, create_node(method_name, @int_10, @int_5).eval
  end
  
  def test_advanced_addition    
    # Create another Addition Node and use it as the left hand
    sub_addition = create_node "addition", @int_5, @int_5
    
    assert_equal 20, create_node(method_name, sub_addition, @int_10).eval
  end
  
  def test_variableassignment
    scope = {} # Empty variable scope to store our test-variable
    
    # Make the assignment
    create_node(method_name, "myVar", @int_10).eval(scope)
    
    assert_equal 10, scope[:myVar] 
  end
  
  def test_scoped_variableassignment
    global_scope = {:another_variable => "yes"}
    scope = {"PARENTSCOPE" => global_scope} # Empty variable scope to store our test-variable
    
    # Make the assignment
    create_node(method_name, "myVar", @int_10).eval(scope)
    assert_equal 10, scope[:myVar]
    assert_nil global_scope[:myVar] # Should not pollute parent-scope
    
    # This time it should find "another_variable" in the parent-scope and overwrite it
    create_node(method_name, "another_variable", @int_5).eval(scope)
    assert_equal 5, global_scope[:another_variable]
    assert_nil scope[:another_variable] # Should not pollute other scopes
  end
  
  def test_variable
    scope = {:myVar => "hej"}
    
  end

end

