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

  def test_dboolean
    assert_equal true, create_node(method_name, true).eval
    assert_equal false, create_node(method_name, false).eval
    assert_equal false, create_node(method_name, nil).eval
    assert_equal false, create_node(method_name, create_node("dinteger", "0")).eval
    assert_equal true, create_node(method_name, create_node("dinteger", "1")).eval
    assert_equal true, create_node(method_name, create_node("dstring", "Yarrr!")).eval
  end

  def test_comparison
    assert_equal true, create_node(method_name, @int_10, "==", @int_10).eval
    assert_equal false, create_node(method_name, @int_10, "==", @int_5).eval
    assert_equal true, create_node(method_name, @int_10, "!=", @int_5).eval
    assert_equal false, create_node(method_name, @int_5, "!=", @int_5).eval
  end

  def test_variableassignment
    scope = {} # Empty variable scope to store our test-variable

    # Make the assignment
    create_node(method_name, "myVar", @int_10).eval(scope)

    assert_equal 10, scope[:myVar]
  end

  def test_scope_variableassignment
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

    assert_equal "hej", create_node(method_name, "myVar").eval(scope)
  end

  def test_scope_variable
    global_scope = {:another_variable => "yes", :myVar => "goodbye"}
    scope = {"PARENTSCOPE" => global_scope, :myVar => "hej"}

    assert_equal "hej", create_node(method_name, "myVar").eval(scope)
    assert_equal "yes", create_node(method_name, "another_variable").eval(scope)
  end

  def test_statementlist
    # Create a bunch of statements
    stmt_1 = create_node "addition", @int_5, @int_10
    stmt_2 = create_node "addition", @int_5, @int_5
    stmt_3 = create_node "multiplication", @int_5, @int_10

    stmt_list_1 = create_node method_name, stmt_1

    stmt_list_1 += create_node(method_name, stmt_2)
    assert_equal 2, stmt_list_1.list.length

    stmt_list_1 += create_node(method_name, stmt_3)
    assert_equal 3, stmt_list_1.list.length
  end

end

