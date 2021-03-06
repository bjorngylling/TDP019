# coding: utf-8

####
# test_helpers.rb
# http://github.com/bjorngylling/TDP019
# Part of the Dunder language project by Björn Gylling and Linus Karlsson
# This file contains helper methods for the tests

require 'lib/dunder.rb'

require 'test/unit'

begin
  require 'rubygems'
  require 'turn'
rescue LoadError
end

class DunderParserTest < Test::Unit::TestCase
  
  def run_output_test(code)
    # Redirect stdout to output
    output = StringIO.new
    old_stdout, $stdout = $stdout, output
            
    @d_parser.parse(code).eval(@global_scope)
    
    # Restore stdout
    $stdout = old_stdout
    
    output.string
  end
  
  def parse(code)
    @d_parser.parse(code).eval(@global_scope)
  end
  
end
  

class Dunder::Nodes::Node
  def self.sub_classes
    sub_classes = ObjectSpace.enum_for(:each_object, class << self; self; end).to_a
    sub_classes.delete(self)
    
    sub_classes
  end
end


class DunderNodesTest < Test::Unit::TestCase
  
  def evaluate(node)
    node.eval(@scope)
  end
  
  ## CREATE_NODE
  #
  # Takes in name of the current test method and returns
  # a Node that is supposed to be tested by that method.
  # It takes anything after the last underscore and uses that
  # to determine which Node it should be. Can also be used
  # to create a different node by passing the node name.
  #
  # Tests testing nodes should always be named: test_NODENAME
  # ex. test_addition tests the node Dunder::Node:Addition
  #
  # Any extra arguments passed are passed along to the initialization of the new node
  # such as the value of a int or the terms in an addition node.
  
  def create_node(test_method, *params)
    # Get available nodes so we can find the one we need, this has to be
    # done since we don't know which letters should be capitalized.
    available_nodes = Dunder::Nodes::Node.sub_classes
    
    node_name_lower_case = "dunder::nodes::#{get_last_word_in test_method}"
    node_name = available_nodes.select { |node| node.to_s.downcase == node_name_lower_case }.first
    
    node_name.new *params
  end
  
  def get_last_word_in(words_seperated_by_underscore)
    words_seperated_by_underscore.split("_").last
  end
  
  def node(*params)
    create_node self.name.split("(").first, *params
  end

  def method_missing(name, *args)
    if name.to_s =~ /^int_(\d+)$/
      return create_node "dinteger", $1
    end
    
    super
  end
end