require 'lib/dunder.rb'

require 'test/unit'

##
# Takes in name of the current test method and returns
# a Node that is supposed to be tested by that method.
# It takes anything after the last underscore and uses that
# to determine which Node it should be.
#
# Tests testing nodes should always be named: test_NODENAME
# ex. test_addition tests the node Dunder::Node:Addition
def create_node(test_method)
  # Get available nodes so we can find the one we need, this has to be
  # done since we don't know which letters should be capitalized.
  available_nodes = Dunder::Nodes::Node.sub_classes
  node_name_lower_case = "dunder::nodes::#{test_method.scan(/[a-z]+$/)[0]}"
  node_name = available_nodes.select { |node| node.to_s.downcase == node_name_lower_case }
  
  eval "#{node_name}.new"
end