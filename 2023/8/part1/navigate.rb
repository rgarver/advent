# frozen_string_literal: true

class Map
  LEFT = 0
  RIGHT = 1

  def initialize
    @locations = {}
  end

  def add_location(name, left, right)
    @locations[name] = [left, right]
  end

  def left_from(location_name)
    @locations[location_name][LEFT]
  end

  def right_from(location_name)
    @locations[location_name][RIGHT]
  end

  def next_location(location_name, direction)
    case direction
    when 'L' then left_from(location_name)
    when 'R' then right_from(location_name)
    else
      raise "Unknown direction: #{direction}"
    end
  end

  def inspect
    @locations.inspect
  end
end

filename = ARGV[0]

lines = File.readlines(filename, chomp: true)

route = lines.shift # first line is the route
lines.shift # second line is the empty line

map = Map.new
lines.each do |line|
  parsed_line = /(\S+) = \(([^,]+), ([^)]+)\)/.match(line)
  map.add_location(parsed_line[1], parsed_line[2], parsed_line[3])
end

puts route
puts map.inspect

current_location = 'AAA'
route_index = 0
while current_location != 'ZZZ'
  current_location = map.next_location(current_location, route[route_index % route.length])
  route_index += 1
end

puts route_index
