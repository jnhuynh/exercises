#!/usr/bin/env ruby

if ARGV.count < 3
  puts "ERROR: not enough arguments"
  puts "Usage: ./apply_changes.rb <input.json> <changes.json> <output.json>"
end

input_file = ARGV[0]
changes_file = ARGV[1]
output_file = ARGV[2]

puts "Input file: #{input_file}"
puts "Changes file: #{changes_file}"
puts "Output file: #{output_file}"