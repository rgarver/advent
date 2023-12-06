# frozen-string-literal: true

require 'strscan'

class AlmanacMap
  attr_reader :source, :dest
  attr_reader :keys_for_lookup

  def initialize(source, dest)
    @source = source
    @dest = dest
    @map = {}
  end

  def add_mapping(source_start, dest_start, length)
    @map[source_start] = dest_start
    @map[source_start + length] ||= source_start + length
  end

  def freeze
    @keys_for_lookup = @map.keys.sort.reverse
    super
  end

  def [](lookup)
    key = keys_for_lookup.bsearch { |k| k <= lookup }
    return lookup if key.nil?

    @map[key] + lookup - key
  end
end

filename = ARGV[0]

scanner = StringScanner.new(File.read(filename))

seed_ranges = []
scanner.skip('seeds: ')
until scanner.skip("\n")
  scanner.scan(/\s*(\d+)\s+(\d+)/)
  seed_ranges << (scanner.captures.first.to_i...(scanner.captures.first.to_i + scanner.captures.last.to_i))
end
puts seed_ranges.inspect

destination_map = {}
until scanner.eos?
  scanner.skip("\n")
  scanner.scan(/([^-]+)-to-([^-]+) map:\n/)
  current_map = destination_map[scanner.captures.last] = AlmanacMap.new(scanner.captures.first, scanner.captures.last)

  while scanner.scan(/(\d+) (\d+) (\d+)/)
    current_map.add_mapping(scanner.captures[1].to_i, scanner.captures[0].to_i, scanner.captures[2].to_i)
    scanner.skip("\n")
  end
  current_map.freeze
end

path = []
destination = 'location'
while destination != 'seed'
  path.unshift(destination_map[destination])
  destination = destination_map[destination].source
end

puts "#{path.map(&:source).join(' -> ')} -> #{path.last.dest}"

workers = seed_ranges.map do |seed_range|
  Ractor.new(seed_range, Ractor.make_shareable(path)) do |seed_range, path|
    min = Float::INFINITY
    iteration = 0
    pct = (seed_range.size / 100).to_i
    pct = 1 if pct.zero?
    seed_range.each do |seed|
      value = path.reduce(seed) { |v, map| map[v] }
      min = value if value < min
      putc '.' if ((iteration += 1) % pct).zero?
    end
    putc '!'
    min
  end
end
puts workers.map(&:take).min
