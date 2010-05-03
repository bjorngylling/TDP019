require "test/test_helpers.rb"

class DunderNodesTest < Test::Unit::TestCase

  def test_addition
    assert_equal 15, node(int_10, int_5).eval
  end

  def test_subtraction
    assert_equal 5, node(int_10, int_5).eval
  end

  def test_multiplication
    assert_equal 50, node(int_10, int_5).eval
  end

  def test_division
    assert_equal 2, node(int_10, int_5).eval
  end

  def test_advanced_addition
    # Create another Addition Node and use it as the left hand
    sub_addition = node int_5, int_6

    assert_equal 21, node(sub_addition, int_10).eval
  end

  def test_dboolean
    assert_equal true, node(true).eval
    assert_equal false, node(false).eval
    assert_equal false, node(nil).eval
    assert_equal false, node(int_0).eval
    assert_equal true, node(int_1).eval
    assert_equal true, node(create_node("dstring", "Yarrr!")).eval
  end

  def test_comparison
    assert_equal true, node(int_10, "==", int_10).eval
    assert_equal false, node(int_10, "==", int_5).eval
    assert_equal true, node(int_10, "!=", int_5).eval
    assert_equal false, node(int_5, "!=", int_5).eval
  end

  def test_ifstatement
    stmt_list = create_node("statementlist", create_node("addition", int_5, int_5))
    condition = create_node("dboolean", true)

    assert_equal 10, node(condition, stmt_list).eval
  end

  def test_variableassignment
    scope = {} # Empty variable scope to store our test-variable

    # Make the assignment
    node("myVar", int_10).eval(scope)

    assert_equal 10, scope[:myVar]
  end

  def test_scope_variableassignment
    global_scope = {:another_variable => "yes"}
    scope = {"PARENTSCOPE" => global_scope} # Empty variable scope to store our test-variable

    # Make the assignment
    node("myVar", int_10).eval(scope)
    assert_equal 10, scope[:myVar]
    assert_nil global_scope[:myVar] # Should not pollute parent-scope

    # This time it should find "another_variable" in the parent-scope and overwrite it
    node("another_variable", int_5).eval(scope)
    assert_equal 5, global_scope[:another_variable]
    assert_nil scope[:another_variable] # Should not pollute other scopes
  end

  def test_variable
    scope = {:myVar => "hej"}

    assert_equal "hej", node("myVar").eval(scope)
  end

  def test_scope_variable
    global_scope = {:another_variable => "yes", :myVar => "goodbye"}
    scope = {"PARENTSCOPE" => global_scope, :myVar => "hej"}

    assert_equal "hej", node("myVar").eval(scope)
    assert_equal "yes", node("another_variable").eval(scope)
  end

  def test_statementlist
    # Create a bunch of statements
    stmt_1 = create_node "addition", int_5, int_10
    stmt_2 = create_node "addition", int_5, int_5
    stmt_3 = create_node "multiplication", int_5, int_10

    stmt_list_1 = create_node method_name, stmt_1

    stmt_list_1 += node(stmt_2)
    assert_equal 2, stmt_list_1.list.length

    stmt_list_1 += node(stmt_3)
    assert_equal 3, stmt_list_1.list.length
  end

end

