# frozen-string-literal: true

require 'strscan'

class AlmanacMap
  attr_reader :source, :dest

  def initialize(source, dest)
    @source = source
    @dest = dest
    @map = {}
  end

  def add_mapping(source_start, dest_start, length)
    @map[source_start] = dest_start
    @map[source_start + length] ||= source_start + length
  end

  def [](lookup)
    key = @map.keys.sort.reverse.bsearch { |k| k <= lookup }
    return lookup if key.nil?

    offest = lookup - key
    @map[key] + offest
  end
end

filename = ARGV[0]

scanner = StringScanner.new(File.read(filename))

seeds = []
scanner.skip('seeds: ')
seeds << scanner.captures.first.to_i while scanner.scan(/\s*(\d+)/)
puts seeds.inspect

destination_map = {}
scanner.skip("\n")

until scanner.eos?
  scanner.skip("\n")
  scanner.scan(/([^-]+)-to-([^-]+) map:\n/)
  current_map = destination_map[scanner.captures.last] = AlmanacMap.new(scanner.captures.first, scanner.captures.last)

  while scanner.scan(/(\d+) (\d+) (\d+)/)
    current_map.add_mapping(scanner.captures[1].to_i, scanner.captures[0].to_i, scanner.captures[2].to_i)
    scanner.skip("\n")
  end
end

path = []
destination = 'location'
while destination != 'seed'
  path.unshift(destination_map[destination])
  destination = destination_map[destination].source
end

puts "#{path.map(&:source).join(' -> ')} -> #{path.last.dest}"

puts(seeds.map do |seed|
  path.reduce(seed) do |value, map|
    map[value]
  end
end.min.inspect)
