require 'lib/dunder.rb'

require 'test/unit'

##
# Takes in name of the current test method and returns
# the name of the node that method is testing
#
# Tests testing nodes should always be named: test_NODENAME
# ex. test_addition tests the node Dunder::Node:Addition
def current_node(test_method)
  # minor errorhandling
  return false unless test_method.include? "_"
  
  eval "Dunder::Nodes::#{test_method.gsub(/[a-z]+_/, "").capitalize}.new"
end