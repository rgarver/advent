#!/usr/bin/env ruby
# frozen_string_literal: true

require 'set'

filename = ARGV[0]

lines = File.readlines(filename, chomp: true)

parts = []
countable_parts = Set.new
grid = {}
last_part = nil

row = 0
lines.each do |line|
  col = 0
  line.each_char do |char|
    if char == '.'
      last_part = nil
    else
      if last_part.nil? || !parts[last_part][:number] || char =~ /^\D$/
        parts << { value: char, number: char =~ /\d/ }
        last_part = parts.size - 1
      else
        parts[last_part][:value] += char
      end
      grid[[row, col]] = last_part

      if parts[last_part][:number]
        if (grid[[row, col - 1]]     && !parts[grid[[row, col - 1]]][:number]) ||
           (grid[[row - 1, col - 1]] && !parts[grid[[row - 1, col - 1]]][:number]) ||
           (grid[[row - 1, col]]     && !parts[grid[[row - 1, col]]][:number]) ||
           (grid[[row - 1, col + 1]] && !parts[grid[[row - 1, col + 1]]][:number])
          countable_parts << last_part
        end
      else
        countable_parts << grid[[row, col - 1]]     if grid[[row, col - 1]]     && parts[grid[[row, col - 1]]][:number]
        countable_parts << grid[[row - 1, col - 1]] if grid[[row - 1, col - 1]] && parts[grid[[row - 1, col - 1]]][:number]
        countable_parts << grid[[row - 1, col]]     if grid[[row - 1, col]]     && parts[grid[[row - 1, col]]][:number]
        countable_parts << grid[[row - 1, col + 1]] if grid[[row - 1, col + 1]] && parts[grid[[row - 1, col + 1]]][:number]
      end
    end
    col += 1
  end
  row += 1
end

puts countable_parts.map { |part| parts[part][:value] }.join(',')
puts(countable_parts.sum { |part| parts[part][:value].to_i })
