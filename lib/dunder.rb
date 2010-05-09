# Require all files in lib/dunder
$:.unshift File.dirname(__FILE__)
Dir["#{File.dirname(__FILE__)}/dunder/*.rb"].each { |format| require "dunder/#{File.basename format}" }
  
def evaluate_file(file_name)
  global_scope = Hash.new
  # code to evaluate passed file
  puts Dunder::Parser.new.parse(read_file_to_string(file_name)).eval(global_scope)
end

def read_file_to_string(file_name)
  File.open(file_name, "r") { |f| f.read.gsub(/\r\n/, "\n") }
end

options = {:v => Proc.new { puts read_file_to_string("VERSION") }, 
           :ip => Proc.new { Dunder::Parser.new.interactive_parser }}

# a flag to start a interactive interpreter
# a flag to check version
if !ARGV.empty?
  flag = ARGV.first.delete("-").to_sym
  if options.has_key? flag
    options[flag].call
  else
    evaluate_file ARGV.first
  end
end
