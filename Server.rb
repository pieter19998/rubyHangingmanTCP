require 'socket'

class Word
  require 'net/http'
  require 'json'

  def initialize
    # @word = getWordFromApi
    @word = %w[b o r]
    @guess = Array.new
  end

  def getGuess
    @guess
  end

  def getWordFromApi
    url = 'https://random-word-api.herokuapp.com/word?number=1'
    uri = URI(url)
    response = Net::HTTP.get(uri)
    data = JSON.parse(response)
    data[0].split("")
  end

  def checkCharacter(character)
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
end

class Server
  def initialize(port, ip)
    @server = TCPServer.open(ip, port)
    @connections = Hash.new
    @rooms = Hash.new
    @clients = Hash.new
    @connections[:server] = @server
    @connections[:clients] = @clients
    run
  end

  def run
    loop {
      Thread.start(@server.accept) do |client|
        nick_name = client.gets.chomp.to_sym
        @connections[:clients].each do |other_name, other_client|
          if nick_name == other_name || client == other_client
            client.puts ":invalid"
            Thread.kill self
          end
        end
        puts "#{nick_name} #{client}"
        @connections[:clients][nick_name] = client
        if @connections[:clients].size == 2
          @connections[:clients].each do |name, player|
            puts name
            listen_user_guess
            break
          end
        else
          client.puts ":wait"
        end
      end
    }.join
  end

  def endGame
    @connections[:clients].each do |name, player|
      puts name
      player.puts(":GameOver")
    end
  end

  def listen_user_guess
    word = Word.new
    @connections[:clients].each do |name, player|
      puts name
      player.puts(":start")
    end
    loop {
      @connections[:clients].each do |name, player|
        player.puts("ENTER A LETTER TO GUESS #{name} \n word: #{word.getGuess}")
        print name.to_s + "   "
        character = player.gets.chomp.to_sym
        print character.to_s + "\n"
        status = word.checkCharacter(character.to_s)
        if status
          endGame
          break
        end
        player.puts("Await your turn \n #{word.getGuess}")
      end
    }
  end
end

Server.new(2000, "localhost")