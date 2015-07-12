class Game
  def initialize players, dictionary
    @players = players
    @fragment = ""
    @dictionary = File.readlines(dictionary).map(&:chomp)
    @losses = Hash.new(0)
  end

  def play_valid? fragment
    @dictionary.any? { |word| word[0...fragment.length] == fragment }
  end

  def game_over?
    @dictionary.any? { |word| word == @fragment }
  end

  def play_round
    puts "Beginning a new round..."
    until game_over?
      puts @fragment
      next_player!
      take_turn(current_player)
    end
    puts "#{current_player.name} lost!"
    @losses[current_player] += 1
  end

  def run
    puts "Welcome to Ghost!"
    until @players.size == 1
      play_round
      @fragment = ""
      display_standings
      @players.each {|player| @players.delete(player) if @losses[player] >= 5}
    end
  end

  def display_standings
    @players.each do |player|
      puts "#{player.name}'s score is #{convert_to_letters(@losses[player])}"
    end
  end

  def convert_to_letters score
    "GHOST"[0...score]
  end

  def current_player
    @players.first
  end

  def previous_player
    @players.last
  end

  def next_player!
    @players.push(@players.shift)
  end

  def take_turn(player)
    letter = player.guess(@fragment, @players.count-1, @dictionary)
    until (letter.length == 1) && (play_valid?(@fragment + letter))
      player.alert_invalid_guess
      letter = player.guess(@fragment, @players.count-1, @dictionary)
    end
    @fragment << letter
  end
end

class SuperGhost < Game
  def take_turn(player)
    letter, pos = player.super_guess(@fragment, @players.count-1, @dictionary)
    new_word = new_fragment(letter,pos)
    until (letter.length == 1) && (play_valid?(new_word))
      player.alert_invalid_guess
      letter,pos = player.super_guess(@fragment, @players.count-1, @dictionary)
      new_word = new_fragment(letter,pos)
    end
    @fragment = new_word
  end

  def new_fragment(letter,pos)
    pos == "f" ? letter + @fragment : @fragment + letter
  end
end

class Player
  attr_reader :name

  def initialize name
    @name = name
  end

  def guess(x,y,z)
    print "Enter your letter, #{name}: "
    gets.chomp.downcase
  end

  def super_guess(x,y,z)
    letter = guess(x,y,z)
    print "Enter F for front or B for back: "
    [letter, gets.chomp.downcase]
  end

  def alert_invalid_guess
    puts "Invalid guess."
  end

end

class AiPlayer
  attr_reader :name

  def initialize name
    @name = name
  end

  def guess fragment, other_players, dictionary
    puts "Computer picking a letter... "
    ("a".."z").each do |letter|
      if winning_move?(fragment + letter,other_players, dictionary)
        return letter
      end
    end
    ("a".."z").to_a.sample
  end

  def winning_move?(fragment, other_players, dictionary)
    return false if losing_move?(fragment, dictionary)
    if dictionary.all? { |word| word[0...fragment.length] != fragment }
      return false
    end
    words = words_containing(fragment, dictionary)
    words.all? { |word| word.length <= (fragment.length + other_players) }
  end

  def words_containing fragment, dictionary
    dictionary.select { |word| word[0...fragment.length] == fragment }
  end

  def losing_move?(fragment, dictionary)
    dictionary.any? { |word| word == fragment }
  end

  def super_guess(fragment, other_players, dictionary)
    puts "Computer picking a letter... "
    ("a".."z").each do |letter|
      if winning_move?(fragment + letter,other_players, dictionary)
        return [letter, "b"]
      elsif winning_move?(letter + fragment,other_players, dictionary)
        return [letter, "f"]
      end
    end
    [("a".."z").to_a.sample, ["b", "f"].sample]
  end

  def alert_invalid_guess

  end
end










g = Game.new([Player.new("ed"),AiPlayer.new("bob")],"ghost-dictionary.txt")
g.run
