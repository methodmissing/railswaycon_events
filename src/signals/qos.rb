class QosWorker
  
  attr_reader :throttle,
              :stats
  
  def initialize
    @throttle = 0
    @stats = Hash.new(0)
    @main_loop = init_main_loop
    init_signal_handlers
  end

  def do_work
    while true do
      load_spike
      signal( 'URG' )
      load_drop
      signal( 'CONT' )
      if rand(3) == 1
        signal( 'XCPU' )
      end     
    end
  end

  def throttle!( name, operation, qos )
    puts name
    @throttle = qos
    @stats[operation] = @stats[operation] + 1
    @main_loop.wakeup  
  end

  def shutdown!
    @main_loop.kill
    puts @stats.inspect
    exit
  end  

  private
  
    def signal( sig )
      Process.kill( sig, Process.pid )
    end
  
    def simulate
      sleep( rand )
    end
    alias :load_drop :simulate
    alias :load_spike :simulate
  
    def init_main_loop
      Thread.new do  
        loop do
          delay if throttle?
          puts "Jobs ... #{@throttle.inspect}s" 
        end
      end 
    end
    
    def init_signal_handlers
      Signal.trap('URG') do
        throttle!( 'Less work ...', :throttle, 0.2 )
      end
      
      Signal.trap('CONT') do
        throttle!( 'Lotta work ...', :default, 0.1 )
      end

      Signal.trap('XCPU') do
        throttle!( 'No work ...', :stop, 5 )
      end

      Signal.trap('INT') do
        shutdown!
      end  
    end
      
    def delay
      sleep( @throttle )
    end
    
    def throttle?
      @throttle != 0
    end
  
end

if __FILE__ == $0
  @worker = QosWorker.new
  @worker.do_work
end