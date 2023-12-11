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

MAP = {}
current_locations = []
lines.each do |line|
  parsed_line = /(\S+) = \(([^,]+), ([^)]+)\)/.match(line)
  MAP[parsed_line[1]] = [parsed_line[2], parsed_line[3]]
  current_locations << parsed_line[1] if parsed_line[1].end_with?('A')
end

puts route
puts MAP.inspect
puts current_locations.inspect

INDEXED_ROUTE = route.chars.map do |direction|
  case direction
  when 'L' then Map::LEFT
  when 'R' then Map::RIGHT
  else
    raise "Unknown direction: #{direction}"
  end
end

route_length = route.length
puts "Route length: #{route_length}"
spacing = []

current_locations.each do |location|
  route_index = 0
  puts "Location: #{location}"
  cur_loc = location
  route_index = 0
  route_index_list = []
  2.times do
    loop do
      cur_loc = MAP[cur_loc][INDEXED_ROUTE[route_index % route_length]]
      route_index += 1
      break if cur_loc.end_with?('Z')
    end
    puts "Cur Loc: #{cur_loc} Route index: #{route_index}"
    route_index_list << route_index
  end
  puts "Cur Loc: #{cur_loc} Route index: #{route_index}"

  spacing << (space = [route_index_list[0], route_index_list[1] - route_index_list[0]])
  puts "Route index: #{route_index_list.inspect}/#{route_length} (#{space[1]}) offset #{space[0] - space[1]}"
end

def compute_lcm_with_offset(spacing_1, offset_1, spacing_2, offset_2)
  old_offset_1, old_offset_2 = offset_1, offset_2
  offset_1, offset_2 = 0, ((old_offset_2 - old_offset_1))
  puts "offset_1: #{offset_1} offset_2: #{offset_2}"
  # Extened Euclidean algorithm https://en.wikipedia.org/wiki/Extended_Euclidean_algorithm
  old_r, r = spacing_1, spacing_2
  old_s, s = 1, 0
  old_t, t = 0, 1

  until r.zero?
    quotient, remainder = old_r.divmod(r)
    old_r, r = r, remainder
    old_s, s = s, (old_s - quotient * s)
    old_t, t = t, (old_t - quotient * t)
  end
  gcd, s, t = old_r, old_s, old_t
  puts "gcd: #{gcd} s: #{s} t: #{t}"

  # a * spacing_1 + offset_1 == Z
  # b * spacing_2 + offset_2 == Z
  # c * spacing_3 + offset_3 == Z
  #
  # Z =


  # z * s * spacing_1 - z * t * spacing_2 == offset_2 - offset_1
  # z = (offset_2 - offset_1) / gcd

  diff = offset_2 - offset_1
  z = diff / gcd

  m = (z * s)
  n = (-1 * z * t)
  puts "m: #{m} n: #{n}"

  n * spacing_2 + old_offset_2
end

# initial_values = spacing.transpose.first
# puts initial_values.inspect

# current_values = initial_values.dup
# until current_values.uniq.size == 1
#   max_value = current_values.max
#   current_values.map!.with_index do |value, idx|
#     value < max_value ? value + spacing[idx][1] : value
#   end
# end

# puts current_values.inspect

STARTING_LOCATIONS = current_locations.dup
def run_to_step(step)
  current_locations = STARTING_LOCATIONS.dup
  route_length = INDEXED_ROUTE.length
  route_index = 0
  until route_index == step
    putc '.' if (route_index % 100_000).zero?
    current_locations.map! do |current_location|
      MAP[current_location][INDEXED_ROUTE[route_index % route_length]]
    end
    route_index += 1
  end
  current_locations
end

puts(first_lcm_with_offset = compute_lcm_with_offset(spacing[0][1], spacing[0][0], spacing[1][1], spacing[1][0]))
# puts run_to_step(first_lcm_with_offset.abs).inspect

lcm = spacing[1..].reduce(first_lcm_with_offset.abs) do |lcm_with_offset, spacing|
  puts "LCM with offset: #{lcm_with_offset}"
  compute_lcm_with_offset(lcm_with_offset, 0, spacing[1], spacing[0]).abs
end
puts lcm

# puts current_locations.inspect
# puts route_index

puts spacing.reduce(1){ |lcm, (_, cycle)| lcm.lcm(cycle) }
