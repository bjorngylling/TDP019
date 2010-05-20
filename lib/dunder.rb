#!/usr/bin/ruby
# coding: utf-8

# Require all files in lib/dunder
$:.unshift File.dirname(__FILE__)
Dir["#{File.dirname(__FILE__)}/dunder/*.rb"].each do 
  |format| require "dunder/#{File.basename format}"
end
  
def evaluate_file(file_name)
  global_scope = Hash.new
  file = read_file_to_string(file_name)
  puts Dunder::Parser.new.parse(file).eval(global_scope)
end

def read_file_to_string(file_name)
  File.open(file_name, "r") { |f| f.read.gsub(/\r\n/, "\n") }
end

options = {:v => Proc.new { puts read_file_to_string("VERSION") }, 
           :ip => Proc.new { Dunder::Parser.new.interactive_parser }}

if !ARGV.empty?
  flag = ARGV.first.delete("-").to_sym
  if options.has_key? flag
    options[flag].call
  else
    evaluate_file ARGV.first
  end
elsif($0.include? "dunder.rb")
  puts "Dunder help:
  Flags:
    -v  Prints the version
    -ip Starts the interactive parser
    
  Pass a file with Dunder-code as the argument and Dunder will run the code in that file."
end
