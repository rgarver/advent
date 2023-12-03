#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require 'strscan'

options = {}
optparse = OptionParser.new do |opts|
  opts.banner = 'Usage: possible_games.rb <filename> [options]'
  opts.on '-r', '--red <red>', 'Number of red tokens' do |red|
    options[:red] = red.to_i
  end
  opts.on '-b', '--blue <blue>', 'Number of blue tokens' do |blue|
    options[:blue] = blue.to_i
  end
  opts.on '-g', '--green <green>', 'Number of green tokens' do |green|
    options[:green] = green.to_i
  end
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
  game = { id: scanner.captures.first.to_i, selections: [] }

  selection = {}
  until scanner.eos?
    selection[scanner.captures.last] = scanner.captures.first.to_i if scanner.scan(/([1-9]\d*) (red|blue|green)/)

    next if scanner.skip(', ')

    if scanner.skip('; ') || scanner.eos?
      game[:selections] << selection
      selection = {}
    end
  end

  games << game
end

puts "Games: #{games.size}"

possible_games = games.select do |game|
  game[:selections].all? do |selection|
    (selection['red'].nil? || selection['red'] <= options[:red]) &&
      (selection['blue'].nil? || selection['blue'] <= options[:blue]) &&
      (selection['green'].nil? || selection['green'] <= options[:green])
  end
end

puts "Possible games: #{possible_games.size}"
puts "Possible games sum: #{possible_games.sum { |game| game[:id] }}"
