require 'rubygems'
require 'eventmachine'

EM.run do
  signature = EM.add_timer(1) do
    puts 'shutdown ...'
    EM.stop
  end
  puts signature.inspect  
end