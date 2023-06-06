#!/usr/bin/env ruby

require 'pry-byebug'

module Validate
  def get_valid_input
    loop do
      input = gets.chomp.split('')
      return input unless input.any? { |digit| !digit.to_i.between?(1, 6) || input.length != 4 }

      puts "You either used a number outside the range of 1-6, or you didn't enter exactly 4 numbers.\nEither way, try again:"
    end
  end
end

class Maker
  attr_accessor :code

  def initialize
    @code = []
  end
end

class HumanMaker < Maker
  include Validate

  def generate_code
    puts 'Enter code:'
    self.code = get_valid_input
    code.map! { |num| num.to_i }
  end
end

class CpuMaker < Maker
  def generate_code
    4.times { code.push(1 + rand(6)) }
  end
end

class Breaker
  attr_accessor :guess, :guesses

  def initialize
    @guess = ''
    @guesses = []
  end
end

class HumanBreaker < Breaker
  include Validate

  def make_guess
    puts "This is guess #{guesses.length + 1}.\nEnter your guess (4 digit code, numbers 1-6):"
    self.guess = get_valid_input
    guesses.push(guess)
  end
end

class CpuBreaker < Breaker
  def make_guess
    puts "Uhh... this isn't done yet"
    exit
  end
end

def choose_player(name)
  puts "#{name} (h)uman or (c)omputer?"
  loop do
    p_choice = gets.chomp
    case name
    when 'Maker' then
      case p_choice
      when 'h' then return HumanMaker.new
      when 'c' then return CpuMaker.new
      else puts 'Invalid option, please choose (h)uman or (c)omputer'
      end
    when 'Breaker' then
      case p_choice
      when 'h' then return HumanBreaker.new
      when 'c' then return CpuBreaker.new
      else puts 'Invalid option, please choose (h)uman or (c)omputer'
      end
    end
  end
end

def check_guess(maker, breaker)
  full_correct = 0
  partial_correct = 0
  scratch_code = maker.code.dup
  breaker.guesses[-1].each_with_index do |guess, index|
    if guess.to_i == scratch_code[index]
      full_correct += 1
      breaker.guesses[-1][index] = nil
      scratch_code[index] = nil
    end
  end
  breaker.guesses[-1].each { |guess| partial_correct += 1 if scratch_code.include? (guess.to_i) }

  puts "You guessed #{full_correct} correctly in the right spot"
  puts "You guess #{partial_correct} correctly in the wrong spot"

  breaker.guesses[-1].compact.empty?
end

def win
  puts 'The code was guessed!'
  exit
end

maker = choose_player('Maker')
breaker = choose_player('Breaker')

maker.generate_code
puts "The code is #{maker.code}"

12.times do
  breaker.make_guess
  check_guess(maker, breaker) and win
end

puts "The code was not guessed! It was #{maker.code}"
