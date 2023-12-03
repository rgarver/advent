#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require 'strscan'

options = {}
optparse = OptionParser.new do |opts|
  opts.banner = 'Usage: possible_games.rb <filename> [options]'
end.parse!

# Check required conditions
if ARGV.empty?
  puts optparse
  exit(-1)
end

options[:filename] = ARGV.shift

# Read file in to separate lines
games_lines = File.readlines(options[:filename], chomp: true)

# Parse each line in to a game hash
games = []
games_lines.each do |line|
  scanner = StringScanner.new(line)
  scanner.scan(/Game (\d+): /)
  game = { id: scanner.captures.first.to_i, red: 0, green: 0, blue: 0}

  until scanner.eos?
    if scanner.scan(/([1-9]\d*) (red|blue|green)/) && game[scanner.captures.last.to_sym] < scanner.captures.first.to_i
      game[scanner.captures.last.to_sym] = scanner.captures.first.to_i
    end

    next if scanner.skip(', ') || scanner.skip('; ') || scanner.eos?
  end

  games << game
end

puts "Games: #{games.size}"

game_powers = games.map { |game| game[:red] * game[:blue] * game[:green] }
puts "Game powers: #{game_powers}"

puts "Game power sum: #{game_powers.sum}"
