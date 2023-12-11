# frozen_string_literal: true

require 'strscan'

filename = ARGV[0]

scanner = StringScanner.new(File.read(filename))

time = ''
scanner.skip(/Time:\s*/)
time += scanner.captures.first while scanner.scan(/(\d+)\s*/)
time = time.to_i

distance = ''
scanner.skip(/Distance:\s*/)
distance += scanner.captures.first while scanner.scan(/(\d+)\s*/)
distance = distance.to_i

max_distance = distance
solution = 0
0.upto(time) do |t|
  solution += 1 if ((time - t) * t) > max_distance
end

puts solution
