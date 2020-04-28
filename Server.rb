require 'socket'
require '../rubyHangingmanTCP/Word'

class Server
  def initialize(port, ip)
    @server = TCPServer.open(ip, port)
    @connections = Hash.new
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

  def send_to_all(message)
    @connections[:clients].each do |name, player|
      player.puts(message)
    end
  end

  def listen_user_guess
    word = Word.new
    send_to_all(":start")
    loop {
      @connections[:clients].each do |name, player|
        player.puts("ENTER A LETTER TO GUESS #{name} \n word: #{word.get_guess} \n USED LETTERS:#{word.get_used_letters}")
        character = player.gets.chomp.to_sym
        print character.to_s + "\n"
        check_character = word.check_character(character.to_s)
        check_word = word.check_word(character.to_s)
        if check_character || check_word || word.get_lives == 7
          send_to_all(":gameover")
          send_to_all("#{name} guessed the word!!!")
          send_to_all(":count")
          break
        end
        word.add_to_list(character)
        send_to_all(":count")
        player.puts("Await your turn \n WORD: #{word.get_guess}")
      end
    }
  end
end

Server.new(2000, "localhost")