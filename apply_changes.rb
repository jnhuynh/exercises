#!/usr/bin/env ruby

require 'json'

if ARGV.count < 3
  puts "ERROR: not enough arguments"
  puts "Usage: ./apply_changes.rb <path_to_input.json> <path_to_changes.json> <path_to_output.json>"
end

input_file_path = ARGV[0]
changes_file_path = ARGV[1]
output_file_path = ARGV[2]

puts "Input file: #{input_file_path}"
puts "Changes file: #{changes_file_path}"
puts "Output file: #{output_file_path}"

begin
  input_file = File.open(input_file_path)
rescue => e
  puts "ERROR: Could open open #{input_file_path} with #{e.message}"
end
input_json = JSON.parse(input_file.read)
puts input_json