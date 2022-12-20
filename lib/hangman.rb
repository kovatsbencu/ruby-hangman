require 'io/console'
require 'yaml'

def generate_word
  file = File.open('words.txt', 'r')
  lines = file.readlines
  file.close
  word = ''
  until (5..12).cover?(word.length)
    word = lines.sample.chop
  end
  word
end

def get_word_status(word)
  Array.new(word.length, '_')
end

def play_game(word, word_status, lives, guesses)
  exit unless word_status.include?('_')

  puts ''
  puts word_status.join(' ')
  puts "You have #{lives} more lives."
  puts "Already used letters: #{guesses.join(', ')}"
  puts 'Enter a letter, or press "0" if you want to save the game and exit:'
  guess = $stdin.getch.downcase
  if guess == '0'
    save_data(guesses, word, lives, word_status)
    puts 'You have saved the game! Thank you for playing!'
    exit
  end
  exit unless guess.match(/[a-zA-Z]/)

  if guesses.include?(guess)
    puts ''
    puts 'You have already guessed this letter!'
    lives
  else
    guesses.push(guess)
  end

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

def save_data(guesses, word, lives, word_status)
  serialized_obj = [word, lives, guesses, word_status]
  data = YAML.dump(serialized_obj)
  File.write('saveddata.yaml', data)
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

def load_data
  data = File.read('saveddata.yaml')
  YAML.safe_load(data)
end

# Here comes the program loop

mode = startup
lives = 6
guesses = []
if mode == '1'
  word = generate_word
  word_status = get_word_status(word)
elsif mode == '2'
  loaded_data = load_data
  word = loaded_data[0]
  lives = loaded_data[1]
  guesses = loaded_data[2]
  word_status = loaded_data[3]
end
puts 'Your word:'
while lives.positive? && word_status.include?('_')
  lives = play_game(word, word_status, lives, guesses)
end
display_result(lives)
puts "The word is: #{word}"
