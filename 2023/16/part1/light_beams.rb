# frozen_string_literal: true

filename = ARGV[0]

class Cell
  def self.from_char(char, x, y)
    case char
    when '.'
      Dot.new(x, y)
    when '|'
      Pipe.new(x, y)
    when '-'
      Dash.new(x, y)
    when '/'
      ForwardSlash.new(x, y)
    when '\\'
      BackSlash.new(x, y)
    end
  end

  def initialize(x, y)
    @x = x
    @y = y
    @exit_counts = { up: 0, down: 0, left: 0, right: 0 }
  end

  def traversed?
    @exit_counts.values.any?(&:positive?)
  end

  def move_from(direction)
    # Returns an array of tuples of the next x/y coordinate and the direction it will enter that cell from
    raise NotImplementedError
  end

  def exit_down
    return if @exit_counts[:down].positive?

    @exit_counts[:down] += 1
    [@x, @y+1, :up]
  end

  def exit_up
    return if @exit_counts[:up].positive?

    @exit_counts[:up] += 1
    [@x, @y-1, :down]
  end

  def exit_right
    return if @exit_counts[:right].positive?

    @exit_counts[:right] += 1
    [@x+1, @y, :left]
  end

  def exit_left
    return if @exit_counts[:left].positive?

    @exit_counts[:left] += 1
    [@x-1, @y, :right]
  end
end

class Dot < Cell
  def move_from(direction)
    case direction
    when :up
      [exit_down]
    when :down
      [exit_up]
    when :left
      [exit_right]
    when :right
      [exit_left]
    end
  end
end

class Pipe < Dot
  def move_from(direction)
    case direction
    when :left, :right
      [exit_up, exit_down]
    else
      super
    end
  end
end

class Dash < Dot
  def move_from(direction)
    case direction
    when :up, :down
      [exit_right, exit_left]
    else
      super
    end
  end
end

class ForwardSlash < Cell
  def move_from(direction)
    case direction
    when :up
      [exit_left]
    when :down
      [exit_right]
    when :left
      [exit_up]
    when :right
      [exit_down]
    end
  end
end

class BackSlash < Cell
  def move_from(direction)
    case direction
    when :up
      [exit_right]
    when :down
      [exit_left]
    when :left
      [exit_down]
    when :right
      [exit_up]
    end
  end
end

grid = File.readlines(filename, chomp: true).map.with_index do |line, y|
  line.chars.map.with_index do |char, x|
    Cell.from_char(char, x, y)
  end
end

next_moves = [[0, 0, :left]]
while next_moves.any?
  puts "Next moves: #{next_moves.inspect}"
  x, y, direction = next_moves.shift
  next if x < 0 || y < 0 || x >= grid[0].length || y >= grid.length

  cell = grid[y][x]
  next_moves += cell.move_from(direction).compact
end

energized = grid.inject(0) do |sum, row|
  putc "\n"
  row.inject(sum) do |sum, cell|
    putc cell.traversed? ? '#' : '.'
    sum + (cell.traversed? ? 1 : 0)
  end
end
  putc "\n"
puts "Energized cells: #{energized}"
