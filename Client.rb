require 'socket'

def commands(command, s)
  case command
  when "help"
    print "options: \n exit: to exit the game \n rules: for rules \n credits: show credits\n"
  when "rules"
    print "Type one letter to guess a letter of the word. \nType two or more letters to guess the word\n"
  when "credits"
    print "hangman ASCII art from: https://gist.github.com/chrishorton/8510732aa9a80a03c829b09f12e20d9c \n"
  else
    if command.length == 1
      s.puts command
    end
  end
end

#listen in background for start command
def listen(s)
  usedLetters = Array.new

  while true
    stop = s.recv(1024)
    case stop.to_s
    when ":start"
      puts stop
      break
    when ":GameOver"
      puts "GAME OVER"
    else
      if stop.length == 1
        usedLetters.push(stop)
      end
      puts stop.to_s
      print ">"
    end
  end
  false
end

def username(s)
  puts "enter a username:"
  name = gets.chomp #chomp of the enter
  s.puts name
  data = s.recv(1024)
  puts data
  sleep(1)
  # puts data
  case data.chomp.to_s
  when ":start"
    game(s)
  when ":wait"
    lobby(s)
  else
    puts "no reaction from server"
    #   #todo fix username thread on server for retry
  end
end

def input(s)
  while true
    print ">"
    command = gets.chomp
    commands(command, s)
  end
end

def game(s)
  puts "Started Game"
  t = Thread.new { Thread.current[:output] = listen(s) }
  i = Thread.new { Thread.current[:output] = input(s) }
  while true
    if t.status == false
      t.kill
      # i.kill
      break
    end
  end
end

def lobby(s)
  puts "waiting for other players"

  t = Thread.new { Thread.current[:output] = listen(s) }
  i = Thread.new { Thread.current[:output] = input(s) }
  while true
    if t.status == false
      t.kill
      i.kill
      break
    end
  end
  game(s)
end

#connect to server
begin
  s = TCPSocket.new 'localhost', 2000
rescue
  abort 'Cant connect to server.'
end

username(s)

s.close # close socket when done

