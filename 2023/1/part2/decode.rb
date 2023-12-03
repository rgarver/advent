#!/usr/bin/env ruby
# frozen_string_literal: true

filename = ARGV[0]

module Advent
  refine String do
    def to_i
      {
        'one' => 1,
        'two' => 2,
        'three' => 3,
        'four' => 4,
        'five' => 5,
        'six' => 6,
        'seven' => 7,
        'eight' => 8,
        'nine' => 9
      }[self] || super
    end
  end
end

using Advent

puts "Decoding #{filename}..."
values = []

File.open(filename, 'r') do |f|
  f.each_line do |line|
    next if line.nil?

    first_num = line[/\D*?(one|two|three|four|five|six|seven|eight|nine|\d).*/, 1]
    last_num = line[/.*(one|two|three|four|five|six|seven|eight|nine|\d)\D*/, 1]
    values << (first_num.to_i * 10 + last_num.to_i)
  end
end

puts "Values: #{values.inspect}"
puts "Count: #{values.count}"
puts "Sum: #{values.sum}"
