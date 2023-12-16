# frozen_string_literal: true

class Grid
  def initialize(grid = [])
    @grid = grid
    @tilt_cache = {}
  end

  def <<(row)
    @grid << row
  end

  def to_s
    @grid.map(&:join).join("\n")
  end

  def weight
    final_weight = 0
    @grid.each.with_index do |row, y|
      final_weight += ((@grid.size - y) * row.count('O'))
    end
    final_weight
  end

  def with_tilt_cache(direction)
    if @tilt_cache[[direction, @grid]]
      @grid = @tilt_cache[[direction, @grid]]
      return
    end

    @old_grid = @grid.dup
    yield
    @tilt_cache[[:north, @old_grid]] = @grid
  end

  def tilt_north!
    with_tilt_cache(:north) do
      last_barriers = Array.new(@grid.first.size, 0)
      @grid.each.with_index do |row, y|
        row.each.with_index do |cell, x|
          case cell
          when 'O'
            @grid[last_barriers[x]][x] = 'O'
            @grid[y][x] = '.' if last_barriers[x] != y
            last_barriers[x] += 1
          when '#'
            last_barriers[x] = y + 1
          end
        end
      end
    end
  end

  def tilt_south!
    with_tilt_cache(:south) do
      last_barriers = Array.new(@grid.first.size, @grid.size - 1)
      (@grid.size - 1).downto(0) do |y|
        row = @grid[y]
        row.each.with_index do |cell, x|
          case cell
          when 'O'
            @grid[last_barriers[x]][x] = 'O'
            @grid[y][x] = '.' if last_barriers[x] != y
            last_barriers[x] -= 1
          when '#'
            last_barriers[x] = y - 1
          end
        end
      end
    end
  end

  def tilt_west!
    with_tilt_cache(:west) do
      @grid.each.with_index do |row, y|
        last_barrier = 0
        row.each.with_index do |cell, x|
          case cell
          when 'O'
            @grid[y][last_barrier] = 'O'
            @grid[y][x] = '.' if last_barrier != x
            last_barrier += 1
          when '#'
            last_barrier = x + 1
          end
        end
      end
    end
  end

  def tilt_east!
    with_tilt_cache(:east) do
      @grid.each.with_index do |row, y|
        last_barrier = row.size - 1
        (row.size - 1).downto(0) do |x|
          cell = row[x]
          case cell
          when 'O'
            @grid[y][last_barrier] = 'O'
            @grid[y][x] = '.' if last_barrier != x
            last_barrier -= 1
          when '#'
            last_barrier = x - 1
          end
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
puts

last_sequence = []
last_sequence_start = 0
current_sequence = []
current_sequence_start = 0
match_count = 0
1_000_000_000.times do |i|
# 10_000.times do |i|
  grid.tilt_north!
  grid.tilt_west!
  grid.tilt_south!
  grid.tilt_east!

  # current_sequence << grid.weight
  # if last_sequence.size == current_sequence.size
  #   if last_sequence == current_sequence
  #     current_sequence = []
  #     match_count += 1
  #   else
  #     match_count = 0
  #     last_sequence = current_sequence.dup
  #     last_sequence_start = current_sequence_start
  #     current_sequence_start = i
  #   end
  # elsif last_sequence.size < current_sequence.size
  #   last_sequence << current_sequence.shift
  #   last_sequence_start = current_sequence_start
  # end

  # break if match_count > 50

  # weight = grid.weight
  # previous_weights[weight] ||= []
  # if previous_weights[weight].size > 1
  #   diff = i - previous_weights[weight].last
  #   puts "#{i+1}: #{diff} #{grid.weight}: #{'.' * diff}"
  # end
  # previous_weights[weight] << i
end

# puts "Match count: #{match_count}"
# puts "Last sequence start: #{last_sequence_start}"
# puts "Last sequence size: #{last_sequence.size}"
# puts "Last sequence: #{last_sequence.inspect}"

# final_weight = last_sequence[(1_000_000_000 - last_sequence_start) % last_sequence.size]
# puts "\nWeight: #{final_weight}"
puts "\nWeight: #{grid.weight}"


# pattern matching.
# loop is 18 steps long. Picked a starting index at 976.
# Computed offset from that starting index with (1_000_000_000-976)%18 = 6
# Looked at the pattern of weights and found that the weight at index 6 from my starting point (starting at 0) is 90176
# Answer: 90176
