require 'socket'
require '../rubyHangingmanTCP/Word'
require '../rubyHangingmanTCP/Hangman'

class Client
  def initialize
    #connect to server
    begin
      @server = TCPSocket.new 'localhost', 2000
      @count = -1
    rescue
      abort 'Cant connect to server.'
    end
  end

  def commands(command)
    case command
    when "help"
      print "options: \n exit: to exit the game \n rules: for rules \n credits: show credits\n"
    when "rules"
      print "Type one letter to guess a letter of the word. \nType two or more letters to guess the word\n"
    when "credits"
      print "hangman ASCII art from: https://gist.github.com/chrishorton/8510732aa9a80a03c829b09f12e20d9c \n"
    else
      @server.puts command
    end
  end

#listen in background for commands
  def listen
    hangman = Hangman.new
    loop do
      stop = @server.recv(1024)

      case stop.chomp.to_s
      when ":start"
        puts stop
        break
      when ":gameover"
        puts stop
        puts "GAME OVER"
        exit
      when ":count"
        puts stop
        @count = @count+1
        puts hangman.getHangman(@count)
        print ">"
      else
        puts stop
        print ">"
      end
    end
    false
  end

  def start
    puts "enter a username:"
    name = gets.chomp #chomp of the enter
    @server.puts name
    data = @server.recv(1024)
    puts data
    case data.chomp.to_s
    when ":start"
      lobby("Await your turn")
    when ":wait"
      lobby
    else
      puts "no reaction from server"
    end
  end

  def input
    loop do
      print ">"
      command = gets.chomp
      commands(command)
    end
  end

  def lobby(text = "waiting for other players")
    puts text

    t = Thread.new { Thread.current[:output] = listen }
    i = Thread.new { Thread.current[:output] = input }
    loop do
      if t.status == false
        t.kill
        i.kill
        break
      end
    end
    lobby
  end
end

c = Client.new
c.start
# close socket when done

