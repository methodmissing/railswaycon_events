$:.unshift File.join( File.dirname( __FILE__ ) , '..', 'vendor', 'eventlet', 'lib')
require 'eventlet'
require 'eventlet/async_channel'

module Football
  include Eventlets
  
  class OneToOnePlay < Channel    
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
      @targets[rand(@targets.size)][:player]
    end
    
  end
  
  class CrossKick < OneToManyPlay
  end  
  
  class CrossHeader < OneToManyPlay
  end      
  
  class Human < Struct.new( :name )

    def to_s
      self.name.to_s 
    end

    private
    
      def interaction( action, other_player, delay )
        EM.add_timer( delay ) do
          channel = OneToOnePlay.new
          Eventlets::Eventlet.spawn do  
            channel.send( [self, action, other_player] )
          end  
          Eventlets::Eventlet.spawn do  
            msg = channel.receive
            puts "#{msg[0]} #{msg[1].to_s} #{msg[2]}"
          end
        end
      end
      
      def interactions( event, msg, delay, &block )
        EM.add_timer( delay ) do
          intr = event.new
          block.call( intr )
          intr.send( msg )
        end
      end
    
  end  
  
  class Player < Human
    
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
    
    def fowls( other_player, delay = 0 )
      interaction( :fowls, other_player, delay )
    end
    
    def punches_at( other_player, delay = 0 )
      interaction( :punches, other_player, delay )
    end

    def punches( direction, delay = 0 )
      interactions( event, [self, :punches, direction] , delay )
    end
    
    def argues_with( player_or_referee, delay = 0 )
      interaction( :argues_with, player_or_referee, delay )
    end  
      
  end

  class Referee < Human
    
    def red_cards( player, delay = 0 )
      interaction( :red_cards, player, delay )
    end
    
  end

end

beckham = Football::Player.new( :beckham )
zidane = Football::Player.new( :zidane )
ronaldo = Football::Player.new( :ronaldo )
saha = Football::Player.new( :saha )

referee = Football::Referee.new( :big_cheese )

EM.run do
  
  beckham.kicks_to( zidane )
  zidane.kicks(:left) do |plrs|
    plrs << ronaldo
    plrs << saha
  end
  ronaldo.fowls( saha, 2 )
  
end