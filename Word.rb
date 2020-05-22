class Word
  require 'net/http'
  require 'json'

  def initialize
    # @word = get_word_api
    @word = %w[b o r]
    @guess = Array.new
    @lives = 0
    @used_letters = Array.new
  end

  def get_guess
    @guess
  end

  def get_lives
    @lives
  end

  def update_lives
    @lives = @lives + 1
  end

  def get_used_letters
    @used_letters
  end

  def get_word_api
    url = 'https://random-word-api.herokuapp.com/word?number=1'
    uri = URI(url)
    response = Net::HTTP.get(uri)
    data = JSON.parse(response)
    data[0].split("")
  end

  def add_to_list(character)
    if character.length == 1
      unless @used_letters.include?(character)
        @used_letters.push(character)
      end
    end
  end

  def check_character(character)
    puts @word
    puts character

    @word.each_with_index do |letter, i|
      if letter == character.to_s
        @guess[i] = character
        puts @guess.to_s
        if @guess == @word
          puts "GAME END"
          return true
        end
      end
    end
    false
  end

  def check_word(word)
    if word == @word.join('').to_s
      puts "XXXXX"
      true
    else
      false
    end
  end
end