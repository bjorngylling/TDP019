# coding: utf-8

####
# nodes_test.rb
# http://github.com/bjorngylling/TDP019
# Part of the Dunder language project by Björn Gylling and Linus Karlsson
# This file contains test-cases testing the nodes

require "test/test_helpers.rb"

class DunderNodesTest < Test::Unit::TestCase
  
  def setup
    @scope = Hash.new
  end

  def test_addition
    assert_equal 15, evaluate(node(int_10, int_5))
  end

  def test_subtraction
    assert_equal 5, evaluate(node(int_10, int_5))
  end

  def test_multiplication
    assert_equal 50, evaluate(node(int_10, int_5))
  end

  def test_division
    assert_equal 2, evaluate(node(int_10, int_5))
  end

  def test_advanced_addition
    # Create another Addition Node and use it as the left hand
    sub_addition = node int_5, int_6

    assert_equal 21, evaluate(node(sub_addition, int_10))
  end

  def test_dboolean
    assert_equal true, evaluate(node(true))
    assert_equal false, evaluate(node(false))
    assert_equal false, evaluate(node(nil))
  end

  def test_comparison
    assert_equal true, evaluate(node(int_10, "==", int_10))
    assert_equal false, evaluate(node(int_10, "==", int_5))
    assert_equal true, evaluate(node(int_10, "!=", int_5))
    assert_equal false, evaluate(node(int_5, "!=", int_5))
  end

  def test_ifstatement
    stmt_list = create_node("statementlist", create_node("addition", int_5, int_5))
    condition = create_node("dboolean", true)

    assert_equal 10, evaluate(node(condition, stmt_list))
  end

  def test_variableassignment
    # Make the assignment
    evaluate(node("myVar", int_10))

    assert_equal 10, @scope[:myVar]
  end

  def test_scope_variableassignment
    global_scope = {:another_variable => "yes"}
    @scope["PARENTSCOPE"] = global_scope # Empty variable scope to store our test-variable

    # Make the assignment
    evaluate(node("myVar", int_10))
    assert_equal 10, @scope[:myVar]
    assert_nil global_scope[:myVar] # Should not pollute parent-scope

    # This time it should find "another_variable" in the parent-scope and overwrite it
    evaluate(node("another_variable", int_5))
    assert_equal 5, global_scope[:another_variable]
    assert_nil @scope[:another_variable] # Should not pollute local scope
  end

  def test_variable
    @scope[:myVar] = "hej"

    assert_equal "hej", evaluate(node("myVar"))
  end

  def test_scope_variable
    global_scope = {:another_variable => "yes", :myVar => "goodbye"}
    @scope["PARENTSCOPE"] = global_scope
    @scope[:myVar] = "hej"

    assert_equal "hej", evaluate(node("myVar"))
    assert_equal "yes", evaluate(node("another_variable"))
  end

  def test_statementlist
    # Create a bunch of statements
    stmt_1 = create_node "addition", int_5, int_10
    stmt_2 = create_node "addition", int_5, int_5
    stmt_3 = create_node "multiplication", int_5, int_10

    stmt_list_1 = node stmt_1

    stmt_list_1 += node stmt_2
    assert_equal 2, stmt_list_1.list.length

    stmt_list_1 += node stmt_3
    assert_equal 3, stmt_list_1.list.length
  end

  def test_functioncall
    global_scope = Hash.new

    # Create a bunch of statements
    stmt_list = Array.new
    stmt_list << create_node("addition", int_5, int_10)
    stmt_list << create_node("addition", int_5, int_5)
    stmt_list << create_node("multiplication", int_5, int_10)

    function = create_node("functiondefinition", "foo", ["a", "b", "c"], stmt_list)
    evaluate function 

    assert_equal 50, evaluate(node("foo", [int_12, int_1, int_3]))
  end

end

