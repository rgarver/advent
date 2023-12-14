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

def mismatched_on_horizontal_mirror(grid, y)
  return false if y <= 0 || y >= grid.size

  mismatched = []
  (0...([y, grid.size - y].min)).each do |from_middle|
    (0...grid.first.size).each do |x|
      mismatched << [y, x] unless grid[y - from_middle - 1][x] == grid[y + from_middle][x]
    end
  end
  mismatched
end

def find_horizontal_mirror(grid)
  (1...(grid.size)).each do |y|
    return y if mismatched_on_horizontal_mirror(grid, y).size == 1
  end
  0
end

def mismatched_on_vertical_mirror(grid, x)
  return false if x <= 0 || x >= grid.first.size

  mismatched = []
  (0...([x, grid.first.size - x].min)).all? do |from_middle|
    (0...grid.size).each do |y|
      mismatched << [y, x] unless grid[y][x - from_middle - 1] == grid[y][x + from_middle]
    end
  end
  mismatched
end

def find_vertical_mirror(grid)
  (1...grid.first.size).each do |x|
    return x if mismatched_on_vertical_mirror(grid, x).size == 1
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
