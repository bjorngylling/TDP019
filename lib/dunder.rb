# Require all files in lib/dunder
$:.unshift File.dirname(__FILE__)
Dir["#{File.dirname(__FILE__)}/dunder/*.rb"].each { |format| require "dunder/#{File.basename format}" }


# a flag to start a interactive interpreter
# a flag to check version
p ARGV


module Dunder
  
  def evaluate_file(file_name)
  # code to evaluate passed file
  
  end
  
end
