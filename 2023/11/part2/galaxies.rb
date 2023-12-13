# frozen_string_literal: true

SPACE_MULTIPLIER = 1000000
filename = ARGV[0]
lines = File.readlines(filename, chomp: true)

empty_rows = (0...lines.length).to_a
empty_columns = (0...lines[0].length).to_a

galaxies = []
lines.each.with_index do |line, row|
  line.each_char.with_index do |char, column|
    if char == '#'
      galaxies << [row, column]
      empty_rows.delete(row)
      empty_columns.delete(column)
    end
  end
end

puts "Galaxies: #{galaxies.length}"
puts "Empty rows: #{empty_rows.length}"
puts "Empty columns: #{empty_columns.length}"

total = 0
galaxies.each.with_index do |galaxy, index|
  galaxies[(index + 1)..].each do |other_galaxy|
    rows = [galaxy.first, other_galaxy.first]
    max_row = rows.max
    min_row = rows.min
    extra_rows = empty_rows.count { |row| row.between?(min_row, max_row) }
    total_rows = max_row - min_row + (extra_rows * SPACE_MULTIPLIER) - extra_rows

    cols = [galaxy.last, other_galaxy.last]
    max_col = cols.max
    min_col = cols.min
    extra_cols = empty_columns.count { |col| col.between?(min_col, max_col) }
    total_cols = max_col - min_col + (extra_cols * SPACE_MULTIPLIER) - extra_cols

    puts "Galaxy #{galaxy.inspect} and galaxy #{other_galaxy.inspect} are #{total_rows + total_cols} apart."
    total += total_rows + total_cols
  end
end
puts total
