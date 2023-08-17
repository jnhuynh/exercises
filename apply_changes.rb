#!/usr/bin/env ruby

require 'json'

# Reads json_file_path and returns Hash representing JSON values.
def open_json(json_file_path)
  begin
    json_file = File.open(json_file_path)
    JSON.parse(json_file.read)
  rescue => e
    puts "ERROR: Could open and parse #{json_file_path} with #{e.message}"
  end
end

def ensure_key_exists_with_type(hash, key, type)
  unless hash[key]
    puts "ERROR: changes.json #{key} must be present"
    exit
  end
  unless hash[key].is_a?(type)
    puts "ERROR: changes.json #{key} must be a #{type}"
    exit
  end
end

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

input_json = open_json(input_file_path)

changes_json = open_json(changes_file_path)
operations = changes_json['operations']
ensure_key_exists_with_type(changes_json, 'operations', Array)