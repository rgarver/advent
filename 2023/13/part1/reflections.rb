# frozen_string_literal: true

filename = ARGV[0]

lines = File.readlines(filename, chomp: true)

grids = [[]]
grid_number = 1
idx = 0
lines.each do |line|
  if line.empty?
    grid_number += 1
    grids << []
    idx = 0
    next
  end
  grids[grid_number - 1][idx] = line.chars
  idx += 1
end
# puts "Grids: #{grids.inspect}"

def is_horizontal_mirror?(grid, y)
  return false if y <= 0 || y >= grid.size

  (0...([y, grid.size - y].min)).all? do |from_middle|
    grid[y - from_middle - 1] == grid[y + from_middle]
  end
end

def find_horizontal_mirror(grid)
  (1...(grid.size)).each do |y|
    return y if is_horizontal_mirror?(grid, y)
  end
  0
end

def is_vertical_mirror?(grid, x)
  return false if x <= 0 || x >= grid.first.size

  (0...([x, grid.first.size - x].min)).all? do |from_middle|
    (0...grid.size).all? do |y|
      grid[y][x - from_middle - 1] == grid[y][x + from_middle]
    end
  end
end

def find_vertical_mirror(grid)
  (1...grid.first.size).each do |x|
    return x if is_vertical_mirror?(grid, x)
  end
  0
end

def print_grid(grid, h, v)
  if v.positive?
    puts " #{' '*(v-1)}><"
  else
    puts ''
  end

  grid.each.with_index do |row, y|
    if h.positive?
      putc y == h-1 ? "V" : y == h ? "^" : " "
    else
      putc ' '
    end
    puts row.join
  end
end

zero_grids = []
result = grids.inject(0) do |sum, grid|
  puts "Horizontal mirror: #{h = find_horizontal_mirror(grid)}"
  puts "Vertical mirror: #{v = find_vertical_mirror(grid)}"
  print_grid(grid, h, v)
  zero_grids << [h, v] if h.zero? && v.zero?
  puts "Value = #{v + (100 * h)}"
  sum + v + (100 * h)
end
print "Result: #{result}\n"
puts "Zero grids: #{zero_grids.size}"
zero_grids.each do |h, v|
  print_grid(grids[0], 0, 0)
end
