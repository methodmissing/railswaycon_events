$:.unshift File.join( File.dirname( __FILE__ ) , '..', 'vendor', 'eventlet', 'lib')
require 'eventlet'
require 'eventlet/async_channel'

module Football
  include Eventlets
  
  class OneToOnePlay < AsyncChannel    
  end
  
  class OneToManyPlay < Event
    class Target < Struct.new(:eventlet, :player)      
    end
    
    def initialize
      super
      @targets = []
    end

    def <<( player )
      evlt = Eventlets::Eventlet.spawn do
        msg = self.wait
        puts "#{msg[0]} #{msg[1].to_s} #{msg[2]} to #{player} ?"
      end
      @targets << Target.new( evlt, player ) 
    end
    
    def random
      @targets.first#[rand(@targets.size)][:player]
    end
    
  end
  
  class CrossKick < OneToManyPlay
  end  
  
  class CrossHeader < OneToManyPlay
  end      
  
  class Player < Struct.new( :name )
    def to_s
      self.name.to_s 
    end
    
    def kicks_to( other_player, delay = 0 )
      interaction( :kicks_to, other_player, delay ) 
    end

    def headers_to( other_player, delay = 0 )
      interaction( :kicks_to, other_player, delay ) 
    end
    
    def kicks( direction, delay = 0, &block )
      interactions( CrossKick, [self, :kicks, direction] , delay, &block )
    end
    
    def headers( direction, delay = 0, &block )
      interactions( CrossHeader, [self, :headers, direction] , delay, &block )
    end    
    
    def fowls( other_player )
      interaction( :fowls, other_player, delay )
    end
    
    def punches_at( other_player )
      interaction( :punches, other_player, delay )
    end

    def punches( direction, delay = 0 )
      interactions( event, [self, :punches, direction] , delay )
    end

    private
    
      def interaction( action, other_player, delay )
        channel = OneToOnePlay.new
        Eventlets::Eventlet.spawn do  
          channel.send( [self, action, other_player] )
        end  
        Eventlets::Eventlet.spawn do  
          msg = channel.receive
          puts "#{msg[0]} #{msg[1].to_s} #{msg[2]}"
        end
      end
      
      def interactions( event, msg, delay, &block )
        EM.add_timer( delay ) do
          intr = event.new
          block.call(intr)
          puts intr.inspect
          intr.send( msg )
        end  
      end
      
  end

  class Team < Struct.new( :name, :players )
    def to_s
      self.name.to_s  
    end      
  end
  
  class Game < Struct.new( :team, :other_team )
  end

end

beckham = Football::Player.new( :beckham )
zidane = Football::Player.new( :zidane )
ronaldo = Football::Player.new( :ronaldo )
saha = Football::Player.new( :saha )

players = [ beckham, zidane, ronaldo, :saha ]

EM.run do
  
  beckham.kicks_to( zidane )
  zidane.kicks(:left) do |plrs|
    plrs << ronaldo
    plrs << saha
  end
  
end