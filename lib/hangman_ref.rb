# frozen_string_literal: true

require 'io/console'
require 'yaml'

# Hangman is a terminal-based implementation of the classic word-guessing game.
# The game consists of guessing the correct letters in a word, with a limited
# number of lives. The game can be saved and resumed at a later time.
#
# The game uses a list of words stored in a file called 'words.txt' for
# generating the word to be guessed.
class Hangman
  MIN_WORD_LENGTH = 5
  MAX_WORD_LENGTH = 12
  LIVES = 6

  def initialize
    @word = generate_word
    @word_status = Array.new(@word.length, '_')
    @lives = LIVES
    @guesses = []
  end

  def play
    puts 'Your word:'
    while @lives.positive? && @word_status.include?('_')
      @lives = play_turn(@word, @word_status, @lives, @guesses)
    end
    display_result(@lives)
    puts "The word is: #{@word}"
  end

  def load_game
    data = File.read('saveddata.yaml')
    loaded_data = YAML.safe_load(data)
    @word = loaded_data[0]
    @lives = loaded_data[1]
    @guesses = loaded_data[2]
    @word_status = loaded_data[3]
  end

  private

  def generate_word
    file = File.open('words.txt', 'r')
    lines = file.readlines
    file.close
    word = ''
    until (MIN_WORD_LENGTH..MAX_WORD_LENGTH).cover?(word.length)
      word = lines.sample.chop
    end
    word
  end

  def play_turn(word, word_status, lives, guesses)
    puts ''
    puts word_status.join(' ')
    puts "You have #{lives} more lives."
    puts "Already used letters: #{guesses.join(', ')}"
    puts 'Enter a letter, or press "0" if you want to save the game and exit:'
    guess = $stdin.getch.downcase
    if guess == '0'
      save_game(guesses, word, lives, word_status)
      puts 'You have saved the game! Thank you for playing!'
      exit
    end

    process_guess(word, word_status, lives, guesses, guess)
  end

  def process_guess(word, word_status, lives, guesses, guess)
    lives = check_if_used(guesses, guess, lives)
    update_word_status(word, word_status, lives, guess)
  end

  def check_if_used(guesses, guess, lives)
    if guesses.include?(guess)
      puts ''
      puts 'You have already guessed this letter!'
      return lives
    else
      guesses.push(guess)
    end
    lives
  end

  def update_word_status(word, word_status, lives, guess)
    if word.chars.include?(guess)
      indexes = (0...word.length).select { |i| word[i] == guess }
      indexes.each { |i| word_status[i] = guess }
    else
      puts 'You have lost a life!'
      lives -= 1
    end
    lives
  end

  def display_result(lives)
    if lives.zero?
      puts 'You have lost!'
    else
      puts 'You have won!'
    end
  end

  def save_game(guesses, word, lives, word_status)
    serialized_obj = [word, lives, guesses, word_status]
    data = YAML.dump(serialized_obj)
    File.write('saveddata.yaml', data)
  end
end

def startup
  input = ''
  until input.include?('1') || input.include?('2')
    puts 'Press 1 to start a new game.'
    puts 'Press 2 to load saved game.'
    input = $stdin.getch
  end
  input
end

# Main program loop

mode = startup
game = Hangman.new
case mode
when '1'
  game.play
when '2'
  game.load_game
  game.play
end
