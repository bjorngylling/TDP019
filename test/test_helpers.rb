require 'lib/dunder.rb'

require 'test/unit'


class Dunder::Nodes::Node
  def self.sub_classes
    sub_classes = ObjectSpace.enum_for(:each_object, class << self; self; end).to_a
    sub_classes.delete(self)
    
    sub_classes
  end
end


class DunderNodesTest < Test::Unit::TestCase
  
  ##
  # Takes in name of the current test method and returns
  # a Node that is supposed to be tested by that method.
  # It takes anything after the last underscore and uses that
  # to determine which Node it should be.
  #
  # Tests testing nodes should always be named: test_NODENAME
  # ex. test_addition tests the node Dunder::Node:Addition
  #
  # Any extra arguments passed are passed along to the initialization of the new node
  def create_node(test_method, *params)
    # Get available nodes so we can find the one we need, this has to be
    # done since we don't know which letters should be capitalized.
    available_nodes = Dunder::Nodes::Node.sub_classes
    node_name_lower_case = "dunder::nodes::#{test_method.scan(/[a-z]+$/)[0]}"
    node_name = available_nodes.select { |node| node.to_s.downcase == node_name_lower_case }.first
    
    node_name.new *params
  end
  
  def node(*params)
    create_node method_name, *params
  end

  def method_missing(name, *args)
    if name.to_s =~ /^int_(\d+)$/
      return create_node "dinteger", $1
    end
    
    super
  end
end