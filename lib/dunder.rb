
# Require all files in lib/dunder
$:.unshift File.dirname(__FILE__)
Dir["#{File.dirname(__FILE__)}/dunder/*.rb"].each { |format| require "dunder/#{File.basename format}" }

module Dunder
  
  # code to evaluate passed file
  # a flag to start a interactive interpreter
  # a flag to check version
  
end
