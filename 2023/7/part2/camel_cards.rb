# frozen_string_literal: true

class Hand
  attr_reader :rank, :hand

  FACE_CARD_VALUES = { 'A' => 14, 'K' => 13, 'Q' => 12, 'J' => 1, 'T' => 10 }.freeze
  FIVE_OF_A_KIND = 7
  FOUR_OF_A_KIND = 6
  FULL_HOUSE = 5
  THREE_OF_A_KIND = 4
  TWO_PAIR = 3
  ONE_PAIR = 2
  HIGH_CARD = 1

  def initialize(hand_string)
    raise ArgumentError if hand_string.size != 5

    @pretty_hand = []
    @hand = []
    hand_string.each_char do |char|
      @pretty_hand << char
      @hand << (char =~ /\d/ ? char.to_i : FACE_CARD_VALUES[char])
    end

    @rank = compute_rank
  end

  def <=>(other)
    rank_comparison = (rank <=> other.rank)
    return rank_comparison unless rank_comparison.zero?

    @hand.each_with_index do |card, index|
      card_comparison = (card <=> other.hand[index])
      return card_comparison unless card_comparison.zero?
    end

    0
  end

  def compute_rank
    label_counts = Hash.new(0)
    @hand.each { |card| label_counts[card] += 1 }

    if (1..4).cover?(label_counts[FACE_CARD_VALUES['J']])
      # Convert all Jokers to the largest card in the hand
      joker_count = label_counts.delete(FACE_CARD_VALUES['J'])
      max_card = label_counts.max_by { |_, v| v }&.first
      label_counts[max_card || FACE_CARD_VALUES['J']] += joker_count
    end

    if label_counts.size == 1
      FIVE_OF_A_KIND
    elsif label_counts.values.include?(4)
      FOUR_OF_A_KIND
    elsif label_counts.values.include?(3)
      label_counts.size == 2 ? FULL_HOUSE : THREE_OF_A_KIND
    elsif label_counts.values.include?(2)
      label_counts.size == 3 ? TWO_PAIR : ONE_PAIR
    else
      HIGH_CARD
    end
  end

  def inspect
    "[#{@pretty_hand.join(', ')}] : #{@rank}"
  end
end

filename = ARGV[0]

lines = File.readlines(filename, chomp: true)
hands = lines.map do |line|
  split_line = line.split(' ')
  [Hand.new(split_line.first), split_line.last.to_i]
end

sorted_hands = hands.sort_by(&:first).reverse
puts sorted_hands.map{ |hand| hand.first.inspect }
# Traverse the sorted hands each_with_index, using the index to compute the winnings. Accumulate the winnings.

winnings = 0
sorted_hands.reverse.each_with_index do |hand_with_bid, index|
  winnings += hand_with_bid.last * (index + 1)
end

puts "Winnings: #{winnings}"
