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

  def directions
    @directions ||= case @char
    when '|' then [:up, :down]
    when '-' then [:left, :right]
    when 'L' then [:up, :right]
    when 'J' then [:up, :left]
    when '7' then [:down, :left]
    when 'F' then [:down, :right]
    when 'S'
      [:up, :down, :left, :right].select { |c| send(c).connections.include?(self) }
    else
      []
    end
  end

  def connections
    @connections ||= directions.map { |d| send(d) }.compact
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

# Identify the loop
loop_pipes = [start]
depth = 0
next_pipes = start.connections
while next_pipes.any?
  depth += 1
  next_pipes = next_pipes.flat_map(&:connections).uniq - loop_pipes
  loop_pipes += next_pipes
end

require 'set'

interior_count = 0
grid.each do |row|
  in_out = 0
  from_up = from_down = false
  row.each do |pipe|
    if loop_pipes.include?(pipe)
      if pipe.directions.include?(:up) && pipe.directions.include?(:down)
        putc '|'
        from_up = from_down = false
        in_out += 1
      elsif from_up
        if pipe.directions.include?(:up)
          putc '~'
          from_up = from_down = false
        elsif pipe.directions.include?(:down)
          putc 'V'
          from_up = from_down = false
          in_out += 1
        end
      elsif from_down
        if pipe.directions.include?(:up)
          putc 'ﬂ'
          from_up = from_down = false
          in_out += 1
        elsif pipe.directions.include?(:down)
          putc '_'
          from_up = from_down = false
        end
      elsif pipe.directions.include?(:up)
        from_up = true
        putc '^'
      elsif pipe.directions.include?(:down)
        from_down = true
        putc 'v'
      else
        putc '-'
      end
    else
      from_up = from_down = false
      if (in_out % 2).zero?
        putc '.'
      else
        putc 'O'
        interior_count += 1
      end
    end
  end
  putc "\n"
end
puts interior_count
