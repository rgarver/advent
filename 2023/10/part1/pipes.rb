# frozen_string_literal: true

filename = ARGV[0]
lines = File.readlines(filename, chomp: true)

class Pipe
  def initialize(char, row, col, grid)
    @char = char
    @row = row
    @col = col
    @grid = grid
  end

  def up; @grid[@row - 1][@col]; end
  def down; @grid[@row + 1][@col]; end
  def left; @grid[@row][@col - 1]; end
  def right; @grid[@row][@col + 1]; end

  def connections
    @connections ||= case @char
                     when '|' then [up, down]
                     when '-' then [left, right]
                     when 'L' then [up, right]
                     when 'J' then [up, left]
                     when '7' then [down, left]
                     when 'F' then [down, right]
                     when 'S'
                       [up, down, left, right].select { |c| c.connections.include?(self) }
                     else
                       []
                     end
  end

  def inspect
    "#{@char} (#{@row}, #{@col})"
  end
end

grid = Array.new(lines.size) { Array.new(lines.first.size) }
start = nil
lines.each_with_index do |line, row|
  line.each_char.with_index do |char, col|
    grid[row][col] = Pipe.new(char, row, col, grid)
    start = grid[row][col] if char == 'S'
  end
end

puts start.inspect
seen_pipes = [start]
depth = 0
next_pipes = start.connections
while next_pipes.any?
  depth += 1
  puts next_pipes.inspect
  next_pipes = next_pipes.flat_map(&:connections).uniq - seen_pipes
  seen_pipes += next_pipes
end
puts depth
