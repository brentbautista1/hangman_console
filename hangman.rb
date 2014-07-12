class Player
	def initialize(name, game)
		@game = game
		@name = name
		@save_name = "player_saves/#{@name}_save.txt"
		@alphabet = ('A'..'Z').to_a
	end
	def save
		Dir.mkdir("player_saves") unless File.directory?('player_saves')
		@save_file = File.open(@save_name, 'w')
		encrypt_word
			@save_file.puts "#{@encrypted_word.join("")}"
			@save_file.puts "#{@game.guess_list.join("")}"
			@save_file.puts "#{@game.mask.join("")}"
		@save_file.close
	end
	def load
		return "No such file found" if not File.exists?(@save_name)
		@load_file = File.open(@save_name, "r")
		loaded_string = @load_file.read.split("\n")
		@game.load_init(decrypt_word(loaded_string[0].split("")), loaded_string[1].split(""), loaded_string[2].split(""))
	end
	private
	def encrypt_word
		@encrypted_word = []
		pointer = 0
		while pointer < @game.word.size
			position = (@alphabet.index(@game.word[pointer]) + 21) % 26
			@encrypted_word << @alphabet[position]
			pointer += 1
		end
	end
	private
	def decrypt_word(word)
		pointer = 0
		@decrypted_word = []
		while pointer < word.size
			position = (@alphabet.index(word[pointer]) - 21) % 26
			@decrypted_word << @alphabet[position]
			pointer += 1
		end
	end
end

class Hangman 
	attr_reader :mask
	attr_reader :guess_list
	attr_reader :word
	def initialize
		unless File.exists?('5desk.txt')
			raise ArgumentError, "Some necessary files are missing!"
		else
			@word_file = File.open('5desk.txt', 'r')
			@words = @word_file.readlines.collect {|word| word.chomp}
			@guess_list = []
			@word = word_generator
			@alphabet = ('A'..'Z').to_a
		end
	end
	def load_init(word, guess_list, mask)
		@guess_list = guess_list
		@mask = mask
		@word = word
	end
	def word_guess(letter)
		@guess_list << letter
		@alphabet[@alphabet.index(letter)] = '-'
		if @word.index(letter)
			pointer = 0
			while pointer < @word.size
				@mask[pointer] = letter if @word[pointer] == letter
				pointer += 1
			end
		end
	end
	def is_in_word?(letter)
		return true if @word.index(letter)
		false
	end
	def word_generator
		word_seed = Random.new_seed % @words.size
		@word = @words[word_seed].upcase.split("")
		@mask = Array.new
		(@word.size).times { @mask << "-" }
		return @word
	end
	def is_letter_valid?(letter)
		#0 if true, 1 if not true, 2 for save game
		return 2 if letter == 'SG'
		return 1 if @alphabet.index(letter)
		0
	end
	def is_game_running?(letter, tries)
		# 0 means that the game is still running
		# 1 means that the game is won
		# 2 means that the game is lost
		return 2 if tries == 6
		return 0 if @mask.index('-')
		return 1
	end
end

puts "Welcome to Hangman!"
puts "Initializing game..."

begin

	game = Hangman.new
	puts "Enter your name: "
	name = gets.chomp.downcase
	player = Player.new(name, game)
=begin
	#starts player guessing
	puts "Guess now! Input any letter or input 'SG' to save game"
	game_status = 0
	tries = 0

	while game_status == 0
		puts "#{game.word}"
		puts "#{game.mask}"
		puts "Number of tries: #{tries}"
		puts "Your guesses: #{game.guess_list}" 
		while true
			guess_letter = gets.chomp.upcase
			if game.is_letter_valid?(guess_letter) == 1
				game.word_guess(guess_letter)
				break
			else
				puts "Your guess is invalid! Guess again." if game.is_letter_valid?(guess_letter) == 0
				if game.is_letter_valid?(guess_letter) == 2
					puts "Game Saved!"
					player.save
				end
			end
		end
		tries += 1 unless game.is_in_word?(guess_letter)
		game_status = game.is_game_running?(guess_letter, tries)
	end
	if game_status == 1
		puts "Congratulations! You won the game!"
	else
		puts "Number of tries exceeded. The word is #{game.word.join("")}"
	end
=end
	player.load
rescue ArgumentError
	puts "Error 404: 5desk.txt is missing! Game cannot initialize."
end
