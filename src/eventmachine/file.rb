require 'rubygems'
require 'eventmachine'

EM.kqueue = true

class HotConfig < EM::FileWatch
  
  attr_accessor :filename,
                :config
  
  class << self
    
    def load( filename )
      c = new( filename )
      c.filename = filename
      c.read
      c.watch
      c  
    end
    
  end
    
  def reload
    puts 'reloaded config'
  end

  def watch
    ::EM.watch_file( @filename, self.class )
  end

  def read
    @config = YAML.load( IO.read( @filename ) )
  end

  def file_modified
    reload
  end

  def file_deleted
    puts 'deleted'
  end

  def unbind
    puts 'unbind'
    EM.stop
  end

end

if __FILE__ == $0
  EM.run do
    config = HotConfig.load( 'config.yml' ) 
    EM.add_timer(1) do
      File.open( config.filename, 'w') do |f| 
        f.puts( YAML.dump( config.config ) ) 
      end 
    end   
  end
end