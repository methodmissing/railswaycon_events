require 'rubygems'
require 'eventmachine'

class Market
  class System

    def initialize( currency_pair )
      @started = Time.now.to_i
      @currency_pair = currency_pair
      @poller = poll_currency_pair!
      self
    end

    def cancel!
      @poller.cancel
      puts "#{@currency_pair} cancelled!"
    end
 
    private 

      def poll_currency_pair!
        EM::PeriodicTimer.new(1){
          puts "#{@currency_pair} is #{rand.inspect}" 
        }
      end

  end    
end

if __FILE__ == $0
  EM.run do
    Market::System.new( 'USD/EUR' )
    Market::System.new( 'USD/JPY' ).cancel!
    Market::System.new( 'USD/ZAR' )
    EM.add_timer(5){ EM.stop }
  end
end