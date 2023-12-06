#!/usr/bin/env ruby
# frozen_string_literal: true

require 'set'
require 'strscan'

filename = ARGV[0]

lines = File.readlines(filename, chomp: true)

score = 0
winning_numbers = Set.new

lines.each do |line|
  scanner = StringScanner.new(line)
  scanner.skip(/Card\s+\d+: /)

  until scanner.skip(/\s+\|/)
    scanner.scan(/\s*(\d+)/)
    winning_numbers << scanner.captures.first.to_i
  end

  exponent = -1
  until scanner.eos?
    scanner.scan(/\s*(\d+)/)
    exponent += 1 if winning_numbers.include?(scanner.captures.first.to_i)
  end
  score += 2**exponent if exponent >= 0

  winning_numbers.clear
end

puts score
