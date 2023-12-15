# frozen_string_literal: true

def hash(str)
  str.each_char.inject(0) do |current_value, char|
    current_value += char.ord
    current_value *= 17
    current_value %= 256
    current_value
  end
end

filename = ARGV[0]
init_sequence = File.read(filename).split(',')

puts init_sequence.map{ |seq| hash(seq) }.sum
