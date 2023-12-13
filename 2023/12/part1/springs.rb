# frozen_string_literal: true

filename = ARGV[0]
lines = File.readlines(filename, chomp: true)

def bit_count(num, max_bits: Float::INFINITY)
  return 0 if num.bit_length.zero?

  count = 0
  0.upto([num.bit_length-1, max_bits-1].compact.min) do |i|
    count += 1 if (num & (1 << i)).positive?
  end
  count
end

def count_permutations(mapped_springs, regions, unknown_indexes, regex) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  num_assigned = mapped_springs.count('#')
  num_expected = regions.sum
  num_missing = num_expected - num_assigned

  permutations = 0
  ((2**num_missing) - 1).upto(2**unknown_indexes.size) do |n|
    next if bit_count(n, max_bits: unknown_indexes.size) != num_missing

    test_string = mapped_springs.dup
    unknown_indexes.each.with_index do |unknown_index, index|
      test_string[unknown_index] = (n & (1 << index)).positive? ? '#' : '.'
    end
    # puts "  #{n}[#{n.to_s(2)}]: #{test_string} #{test_string =~ regex ? 'matches' : 'does not match'}"
    permutations += 1 if test_string =~ regex
  end
  permutations
end

total_permutations = 0
lines.each do |line|
  mapped_springs, regions = line.split(' ')
  regions = regions.split(',').map(&:to_i)
  puts "Line: #{line}"

  regex = /\A\.*#{regions.map { |n| "\#{#{n}}" }.join('\.+')}\.*\z/
  puts "  Regex: #{regex}"

  unknown_indexes = []
  mapped_springs.each_char.with_index do |char, index|
    unknown_indexes << index if char == '?'
  end
  puts "  Unknown indexes: #{unknown_indexes.inspect}"

  total_permutations += count_permutations(mapped_springs, regions, unknown_indexes, regex)
end
puts total_permutations
