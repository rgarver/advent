# frozen_string_literal: true

class Grid
  def initialize(grid = [])
    @grid = grid
    @weight = 0
  end

  def <<(row)
    @grid << row
  end

  def to_s
    @grid.map(&:join).join("\n")
  end

  def weight
    @weight
  end

  def tilt_north
    Grid.new(@grid).tap do |grid|
      grid.tilt_north!
    end
  end

  def tilt_north!
    @grid.transpose.map.with_index do |col, col_index|
      last_barrier = 0
      col.each.with_index do |cell, row_index|
        case cell
        when 'O'
          @grid[last_barrier][col_index] = 'O'
          @grid[row_index][col_index] = '.' if last_barrier != row_index
          @weight += col.size - last_barrier
          last_barrier += 1
        when '#'
          last_barrier = row_index + 1
        end
      end
    end
  end
end

filename = ARGV[0]

lines = File.readlines(filename, chomp: true)
grid = Grid.new
lines.each do |line|
  grid << line.each_char.to_a
end

puts grid

puts "\nTilt north..."

new_grid = grid.tilt_north
puts new_grid

puts "\nWeight: #{new_grid.weight}"
