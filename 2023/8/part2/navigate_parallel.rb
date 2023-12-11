# frozen_string_literal: true

class Map
  LEFT = 0
  RIGHT = 1

  # Optimized away
end

filename = ARGV[0]

lines = File.readlines(filename, chomp: true)

route = lines.shift # first line is the route
lines.shift # second line is the empty line

map = {}
current_locations = []
lines.each do |line|
  parsed_line = /(\S+) = \(([^,]+), ([^)]+)\)/.match(line)
  map[parsed_line[1]] = [parsed_line[2], parsed_line[3]]
  current_locations << parsed_line[1] if parsed_line[1].end_with?('A')
end

puts route
puts map.inspect
puts current_locations.inspect

indexed_route = route.chars.map do |direction|
  case direction
  when 'L' then Map::LEFT
  when 'R' then Map::RIGHT
  else
    raise "Unknown direction: #{direction}"
  end
end

ractors = current_locations.map do |location|
  Ractor.new(location, map, indexed_route) do |location, map, indexed_route|
    route_index = 0
    route_length = indexed_route.length

    loop do
      location = map[location][indexed_route[route_index % route_length]]
      route_index += 1
      putc '.' if (route_index % 600_000).zero?
      Ractor.yield route_index if location.end_with?('Z')
    end
  end
end

results = Hash.new(0)
loop do
  _ractor, route_index = Ractor.select(*ractors)
  results[route_index] += 1
  if results[route_index] == current_locations.length
    puts "Route index: #{route_index}"
    exit 0
  end
end
