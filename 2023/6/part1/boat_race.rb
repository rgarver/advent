# frozen_string_literal: true

require 'strscan'

filename = ARGV[0]

scanner = StringScanner.new(File.read(filename))

times = []
scanner.skip(/Time:\s*/)
times << scanner.captures.first.to_i while scanner.scan(/(\d+)\s*/)

distances = []
scanner.skip(/Distance:\s*/)
distances << scanner.captures.first.to_i while scanner.scan(/(\d+)\s*/)

solutions = []
times.each_with_index do |time, index|
  max_distance = distances[index]
  solutions[index] = 0
  0.upto(time) do |t|
    solutions[index] += 1 if ((time - t) * t) > max_distance
  end
end

puts solutions.join(',')
puts solutions.reduce(:*)
