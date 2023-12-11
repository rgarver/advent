# frozen_string_literal: true

filename = ARGV[0]

lines = File.readlines(filename, chomp: true)

predicted_values = []
lines.each do |line|
  values = line.split(' ').map(&:to_i)
  differences = [values]
  loop do
    puts differences.last.inspect
    new_difference = []
    differences.last.each_cons(2) { |a, b| new_difference << (b - a) }
    differences << new_difference
    break if differences.last.all?(&:zero?)
  end
  puts differences.last.inspect

  differences.reverse.each_cons(2) do |(diffs1, diffs2)|
    diffs2.unshift(diffs2.first - diffs1.first)
  end

  puts "Final differences:"
  puts differences.map(&:inspect).join("\n")

  predicted_values << differences.first.first
end

puts 'Predicted values:'
puts predicted_values.inspect
puts "Sum of predicted values: #{predicted_values.sum}"
