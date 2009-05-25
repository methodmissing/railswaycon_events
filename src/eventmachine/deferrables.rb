require 'rubygems'
require 'eventmachine'

class Uploader
  class AsyncUpload
    include ::EventMachine::Deferrable
    
    PATH = '/some/folder'.freeze
    
    def initialize( filename )
      @filename = filename
      timeout 1
      setup_callbacks
      process!
    end   
    
    def process!
      begin 
        overhead = rand
        EM::Timer.new( overhead ){
          succeed( upload_path, overhead )         
        }
      rescue => exception
        fail exception
      end  
    end
    
    private
    
      def setup_callbacks
        errback{|ex| puts "err: #{ex.inspect}"  }
        callback{|path,overhead| puts "uploaded to #{path} (#{overhead.inspect})" }
      end
      
      def upload_path
        File.join( PATH, @filename )
      end
    
  end    
  
  def process( filename )
    AsyncUpload.new( filename )
  end  
  
end

if __FILE__ == $0
  EM.run do
    uploader = Uploader.new 
    ( 'a'..'f' ).each do |f|
      uploader.process( f )
    end  
    EM.add_timer(1.2){ EM.stop } 
  end
end