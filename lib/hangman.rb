require 'json'

class Hangman
  @@BODY_PARTS = ['Head', 'Body', 'Left Arm', 'Right Arm', 'Left Leg', 'Right Leg']
    def initialize
      @secret_word = ''
      @incorrect_letters = []
      @body_parts = []
      @board = ''
    end

    def main_menu
      message = "Welcome to hangman! Please select an option"
      game_mode = '0'
      until game_mode.between?('1','4') and game_mode.length == 1
        puts message
        puts "1. Play a new game of Hangman"
        puts "2. Continue from last saved Hangman game"
        puts "3. How to play"
        puts "4. Quit"
        game_mode = gets.chomp
        message = "Please make a valid selection(1-4)"
      end
      game_mode
    end

    def start
      game_mode = main_menu
      case game_mode
        when '1' then play_new_game
        when '2' then play_from_save
        when '3' then how_to_play
        when '4' then return
      end 
    end

    def play_new_game
      begin
        words = File.readlines('google-10000-english-no-swears.txt')
      rescue
        puts "Cannot load words"
        return
      end
      @secret_word = ""
      until @secret_word.length.between?(5,12)
        @secret_word = words[rand(1..words.length)].gsub!(/[\s+]/,'') #account for new line at end of each word
      end
      @board = @secret_word.gsub(/[a-z]/,'_')
      @incorrect_letters = [];
      @body_parts = []
      play

    end

    def play_from_save
      begin
        data = JSON.parse(File.read('saves/save_state.json'))
        @secret_word = data['secret_word'];
        @board = data['board']
        @incorrect_letters = data['incorrect_letters']
      rescue
        "Could not load the save file. It may have been deleted. Please start a new game"
        start
        return
      end
      play
    end

    def play
      message = "Sorry, you lost! The secret word was: #{@secret_word}"
      until @incorrect_letters.length == 6 || @board.gsub(/[\s+]/,'') == @secret_word
        print_game
        puts
        puts "Please enter a letter to guess, or type 'SAVE' to save the game: "
        guess = gets.chomp
        guess.downcase!
        until (guess.between?('a','z') && guess.length == 1) && !@incorrect_letters.include?(guess) && !@board.include?(guess)
          (save_game ; return) if guess.downcase == 'save'
          puts "Please enter a valid, unguessed letter to guess, or 'SAVE' the game: "
          guess = gets.chomp
          guess.downcase!
        end
        @secret_word.include?(guess) ? (puts "Great guess!" ; update_board(guess)) : (puts "Sorry, that letter was not in the word" ; @incorrect_letters.push(guess) ; @body_parts.push(@@BODY_PARTS[@incorrect_letters.length-1]))
        (message = "Congratulations! You won! The secret word was: #{@secret_word}"; break) if @board.gsub(/[\s+]/,'') == @secret_word
      end
      puts message
      puts
      start
    end

    def update_board(guess)
      (0..@secret_word.length).find_all {|index| @secret_word[index] == guess}.each {|element| @board[element] = guess}
    end    

    def print_game
      puts "Incorrect Letters: " + @incorrect_letters.join(' ')
      puts
      puts "Body parts: " + @body_parts.join(', ')
      puts
      puts @board.chars.join(' ')
    end

    def how_to_play
      puts "Hangman is a game where the player has to guess a secret word."
      puts
      puts "The word is in the United States English language. The board contains a '_' for each letter of the secret word"
      puts
      puts "Each turn, the player guesses a letter (a-z). If the letter is part of the secret word, the '_' is replaced with the letter everywhere in the word"
      puts
      puts "The player continues to guess letters until 6 incorrect letters have been guessed. There are 6 incorrect guesses because there are 6 parts of the body(Head, Body, Right Arm, Left Arm, Right Leg, Left Leg)"
      puts
      puts "Example: \nSecret Word = hangman"
      puts
      puts "Board = _ a _ g _ a _"
      puts
      puts "Incorrect Letters = z , b , e"
      puts
      puts "Body Parts: Head, Body, Left Arm"
      puts
      start
    end

    def save_game
      puts "You are about to overwrite any potential existing save data. Are you sure you wish to continue? (y/n)"
      input = gets.chomp
      message = "Game was not saved"
      (
        Dir.mkdir('saves') unless Dir.exist?('saves')
        save_file = File.open('saves/save_state.json','w') #w to overwrite any previous data
        save_file.write JSON.pretty_generate({:secret_word => @secret_word , :board => @board, :incorrect_letters => @incorrect_letters, :body_parts => @body_parts})
        save_file.close
        message = "Game saved!"
      ) if input.downcase == 'y' || input.downcase == 'yes'
      puts message
      puts
      start #go back to main menu
    end
end


hangman = Hangman.new
hangman.start