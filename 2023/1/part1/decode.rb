#!/usr/bin/env ruby
# frozen_string_literal: true

filename = ARGV[0]

puts "Decoding #{filename}..."
values = []

File.open(filename, 'r') do |f|
  f.each_line do |line|
    next if line.nil?

    first_num = line[/\D*(\d).*/, 1]
    last_num = line[/.*(\d)\D*/, 1]
    values << (first_num + last_num).to_i
  end
end

puts "Values: #{values.inspect}"
puts "Count: #{values.count}"
puts "Sum: #{values.sum}"
