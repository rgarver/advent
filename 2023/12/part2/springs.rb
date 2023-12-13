# frozen_string_literal: true

def bit_count(num, max_bits: Float::INFINITY)
  return 0 if num.bit_length.zero?

  count = 0
  0.upto([num.bit_length-1, max_bits-1].compact.min) do |i|
    count += 1 if (num & (1 << i)).positive?
  end
  count
end

$cache = {}
# def count_regions(string)
#   if string.size == 1
#     return string == '?' ? ['.', '#'] : [string]
#   end

#   $cache[string] = string.split('.').reject(&:empty?).flat_map do |sub_string|
#     count_regions(sub_string)
#   end
# end

# def count_permutations(mapped_springs, unknown_indexes, regex) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
#   build_permutations(mapped_springs).count do |permutation|
#     permutation =~ regex
#   end
# end

# ???.### 1, 1, 3

# ['???', '###'] 1,1,3
# ['??', '###'] ['#??', '###'] - ['#?', '###'] ['?', '###'] |
# ['?', '###'] ['##', '###'] | ['##?', '###'] ['#', '?', '###']
# ['#', '###'] ['###'] | [][][] | ['##', '###'] ['###', '###'] | ['#', '###'] ['#', '#', '###']


def count_permutations(collapsed_map, regions)
  # puts "  #{collapsed_map.inspect} #{collapsed_map.map(&:size)} #{regions.inspect}"
  $cache[[collapsed_map, regions]] ||= if collapsed_map.empty? && regions.empty?
    1
  elsif collapsed_map.first =~ /^#+$/ && collapsed_map.first.size == regions.first
    count_permutations(collapsed_map[1..], regions[1..])
  elsif (first_question = collapsed_map.first&.index('?'))
    s = collapsed_map.first
    remove_question = s.dup.tap { |ss| ss[first_question] = '#' }
    split_question = [s[...first_question], s[(first_question + 1)..]]
    count_permutations(collapsed_map.dup.tap { |cm| cm[0] = remove_question }, regions) +
      count_permutations(
        collapsed_map.dup.tap { |cm| cm[0] = split_question }.flatten.reject(&:empty?),
        regions
      )
  else
    0
  end
end

raise 'bit_count(0) != 0' unless bit_count(0) == 0
raise "bit_count(1) != 1 #{bit_count(0)}" unless bit_count(1) == 1
raise "bit_count(2) != 1 #{bit_count(2)}" unless bit_count(2) == 1
raise 'bit_count(3) != 2' unless bit_count(3) == 2
raise 'bit_count(4, max_bits: 2) != 0' unless bit_count(4, max_bits: 2) == 0

filename = ARGV[0]
lines = File.readlines(filename, chomp: true)

total_permutations = 0
lines.each do |line|
  mapped_springs, regions = line.split(' ')
  regions = regions.split(',').map(&:to_i)
  puts "Line: #{mapped_springs} #{regions.inspect}"

  mapped_springs = ([mapped_springs] * 5).join('?')
  regions = regions * 5
  puts "  Mapped springs: #{mapped_springs}"
  puts "  Regions: #{regions.inspect}"

  regex = /\A\.*#{regions.map { |n| '\#' * n }.join('\.+')}\.*\z/
  puts "  Regex: #{regex.inspect}"

  # extended_mapped_springs = "#{mapped_springs[-1]}?#{mapped_springs}"
  # extended_regex = /\A#{Regexp.escape(mapped_springs[-1])}\.*#{regions.map { |n| '\#' * n }.join('\.+')}\.*\z/
  # puts "  Extended regex: #{extended_regex.inspect}"

  unknown_indexes = []
  mapped_springs.each_char.with_index do |char, index|
    unknown_indexes << index if char == '?'
  end
  puts "  Unknown indexes: #{unknown_indexes.inspect}"
  # extended_unknown_indexes = unknown_indexes.map { |n| n + 2 }
  # extended_unknown_indexes.unshift(1)
  # puts "  Extended unknown indexes: #{extended_unknown_indexes.inspect}"

  # permutations = count_permutations(mapped_springs, unknown_indexes, regex)
  permutations = count_permutations(mapped_springs.split('.').reject(&:empty?), regions)
  puts "  Permutations: #{permutations}"

  # extended_permutations = count_permutations(extended_mapped_springs, regions, extended_unknown_indexes, extended_regex)
  # puts "  Extended permutations: #{extended_permutations}"

  # full_permutations = permutations * (extended_permutations**4)
  # puts "  Full permutations: #{full_permutations}"
  total_permutations += permutations
end
puts total_permutations
