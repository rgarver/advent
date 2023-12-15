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

# puts init_sequence.map{ |seq| hash(seq) }.sum

def print_boxes(boxes)
  boxes.each.with_index do |box, index|
    next if box.empty?

    puts "Box #{index}: #{box.map(&:inspect).join(' ')}"
  end
end

boxes = Array.new(256) { [] }

init_sequence.each do |sequence|
  if sequence.end_with?('-')
    label = sequence[0..-2]
    box_index = hash(label)
    boxes[box_index].reject! { |lense| lense.first == label }
  else # =
    label, value = sequence.split('=')
    box_index = hash(label)
    idx = boxes[box_index].find_index { |lense| lense.first == label }
    if idx
      boxes[box_index][idx] = [label, value.to_i]
    else
      boxes[box_index] << [label, value.to_i]
    end
  end
end

total_power = boxes.map.with_index do |box, index|
  box.map.with_index do |lense, lense_index|
    power = (index + 1) * (lense_index + 1) * lense.last
    puts "#{lense.first}: #{index + 1} (box #{index}) * #{lense_index + 1} * #{lense.last} = #{power}"
    power
  end.sum
end.sum
puts "Total power: #{total_power}"
