#!/usr/bin/env ruby
# frozen_string_literal: true

require 'set'

class Part
  attr_reader :value, :gear_ratio_parts

  def initialize(value)
    @value = value
    @gear_ratio_parts = Set.new
  end

  def to_i
    raise unless number?

    @value.to_i
  end

  def append(char)
    raise unless number?

    @value += char
  end

  def number?
    @number ||= @value =~ /^\d+$/
  end

  def possible_gear?
    @possible_gear ||= @value == '*'
  end

  def actual_gear?
    @gear_ratio_parts.size > 1
  end

  def add_gear_ratio(part)
    raise unless possible_gear? && part.number?

    @gear_ratio_parts << part
  end

  def gear_ratio
    @gear_ratio ||= @gear_ratio_parts.map(&:to_i).inject(:*)
  end
end

class Grid
  attr_reader :parts

  def initialize
    @grid = {}
    @parts = []
  end

  def set(row, col, part)
    @parts << part
    @grid[[row, col]] = @parts.size - 1
  end

  def append_at(row, col, char)
    part = at(row, col - 1)
    part.append(char)
    @grid[[row, col]] = @grid[[row, col - 1]]
  end

  def at(row, col)
    @grid[[row, col]] && @parts[@grid[[row, col]]]
  end
end

filename = ARGV[0]

lines = File.readlines(filename, chomp: true)

grid = Grid.new
last_part = nil

row = 0
lines.each do |line|
  col = 0
  line.each_char do |char|
    if char == '.'
      last_part = nil
    else
      if last_part.nil? || !last_part.number? || char =~ /^\D$/
        last_part = Part.new(char)
        grid.set(row, col, last_part)
      else
        grid.append_at(row, col, char)
      end

      if last_part.number?
        grid.at(row, col - 1).add_gear_ratio(last_part)     if grid.at(row, col - 1)&.possible_gear?
        grid.at(row - 1, col - 1).add_gear_ratio(last_part) if grid.at(row - 1, col - 1)&.possible_gear?
        grid.at(row - 1, col).add_gear_ratio(last_part)     if grid.at(row - 1, col)&.possible_gear?
        grid.at(row - 1, col + 1).add_gear_ratio(last_part) if grid.at(row - 1, col + 1)&.possible_gear?
      elsif last_part.possible_gear?
        last_part.add_gear_ratio(grid.at(row, col - 1))     if grid.at(row, col - 1)&.number?
        last_part.add_gear_ratio(grid.at(row - 1, col - 1)) if grid.at(row - 1, col - 1)&.number?
        last_part.add_gear_ratio(grid.at(row - 1, col))     if grid.at(row - 1, col)&.number?
        last_part.add_gear_ratio(grid.at(row - 1, col + 1)) if grid.at(row - 1, col + 1)&.number?
      end
    end
    col += 1
  end
  row += 1
end

puts grid.parts.select(&:actual_gear?).map(&:gear_ratio_parts).join("\n")
puts grid.parts.select(&:actual_gear?).sum(&:gear_ratio)
