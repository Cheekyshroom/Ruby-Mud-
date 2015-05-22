def vowel? letter
  "aeiouAEIOU"[letter] 
end
def aOrAn word
   (vowel? word[0]) ? "an" : "a"
end
class Obj
   @@count = 0
   attr_accessor :name, :properties, :id   
   def initialize name, properties
      @name = name
      @properties = properties
      @id = @@count
      @@count +=1
   end
   def description
      "#{aOrAn @name} #{@name}"
   end
end
def describeObjects os
   if os.length == 0
      "nothing"
   else
      os[0].description + os[1..-1].inject("") do |acc, o|
         acc += " and " + o.description
      end
   end
end
def removeObj name, os
   o = os.inject nil do |ac, o|
      ac = o if o.name == name
      ac
   end
   os.delete o if o
   o
end
class Room
   attr_accessor :description, :exits, :objects, :living
   def initialize d="", o=[], e={}
      @description = d
      @exits = e
      @objects = o
      @living = []
   end
   def description
      "This room is #{@description}.\n"+
      "You see #{describeObjects @objects}.\n"+
      "In this room stands #{describeLiving @living}.\n"+
      "Known exits are #{describeExits @exits}.\n"
   end
   def connect dTo, room, dFrom
      @exits[dTo] = room
      room.exits[dFrom] = self
   end
   def describeExits es
      if es.length == 0
         "none"
      else
         esPrime = es.keys
         esPrime[0] + esPrime[1..-1].inject("") do |acc, o|
            acc += " and " + o
         end
      end
   end
   def describeLiving ls
      if ls.length == 0
         "nobody"
      else
         ls[0].name + ls[1..-1].inject("") do |acc, o|
            acc += " and " + o.name
         end
      end
   end
end

$defaultActions = {
   "take"=>lambda do |player, words|
      obj = removeObj words[0], player.room.objects
      if obj
         player.out.puts "Taking #{words[0]}"
         player.inventory.push obj
      else
         player.out.puts "You can't see any of that."
      end
   end,
   "drop"=>lambda do |player, words|
      obj = removeObj words[0], player.inventory
      if obj
         player.out.puts "Dropping #{words[0]}"
         player.room.objects.push obj
      else
         player.out.puts "You don't have that."
      end
   end,
   "inventory"=>lambda do |player, words|
      player.out.puts "You have with you..."
      player.out.puts describeObjects player.inventory
   end,
   "look"=>lambda do |player, words|
      player.out.puts player.room.description
   end,
   "go"=>lambda do |player, words|
      player.move words[0]
   end,
}
class Player
   attr_accessor :room, :name, :in, :out, :game, :inventory, :actions
   def initialize n, as=$defaultActions, i=$stdin, o=$stdout
      @name = n
      @in = i
      @out = o
      @game = nil
      @inventory = []
      @actions = as
   end
   def playTurn
      if @game
         input = @in.gets.chomp
         words = input.split ' '
         if @actions[words[0]]
            @actions[words[0]].call self, words[1..-1]
         elsif @room.exits[input]
            move input
         elsif input == "quit"
            @game.quit = true
         else
            @out.puts "Give me a command I understand."
         end
         @out.puts ""
      end
   end
   def move direction
      @room.living -= [self]
      @room = @room.exits[direction]
      @room.living += [self]
      @out.puts @room.description
   end
end

class Game
   attr_accessor :players, :mapHead, :quit
   def initialize m
      @mapHead = m
      @players = []
      @quit = false
   end
   def play
      while !@quit do
         @players.each do |player|
            player.playTurn
         end
      end
   end
   def add player
      player.game = self
      player.room = @mapHead
      player.room.living += [player]
      @players.push(player)
      player.out.puts "Welcome."
   end
end

apple = Obj.new "apple", [:fruit, :edible]
banana = Obj.new "banana", [:fruit, :edible]
boot = Obj.new "boot", [:wearable]
bedroom = Room.new "a bedroom", [apple, banana]
hallway = Room.new "a hallway"
hallwayEnd = Room.new "the end of a hallway", [boot]
hallway.connect "west", hallwayEnd, "east"
bedroom.connect "south", hallway, "north"

g = Game.new bedroom
g.add Player.new "Jim"
g.play
