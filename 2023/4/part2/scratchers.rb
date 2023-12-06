#!/usr/bin/env ruby
# frozen_string_literal: true

require 'set'
require 'strscan'

filename = ARGV[0]

lines = File.readlines(filename, chomp: true)

total_scratchers = 0
card_copies = Array.new(lines.size, 1)
winning_numbers = Set.new

lines.each do |line|
  scanner = StringScanner.new(line)
  scanner.skip(/Card\s+(\d+): /)
  card_index = scanner.captures.first.to_i - 1

  until scanner.skip(/\s+\|/)
    scanner.scan(/\s*(\d+)/)
    winning_numbers << scanner.captures.first.to_i
  end

  num_matches = 0
  until scanner.eos?
    scanner.scan(/\s*(\d+)/)
    num_matches += 1 if winning_numbers.include?(scanner.captures.first.to_i)
  end

  if num_matches.positive?
    ((card_index + 1)..(card_index + num_matches)).each { |n| card_copies[n] += card_copies[card_index] }
  end
  total_scratchers += card_copies[card_index]

  winning_numbers.clear
end

puts card_copies.inspect
puts total_scratchers
