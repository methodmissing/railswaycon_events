require 'rubygems'
require 'eventmachine'

class Object
  
  def evented?
    Object.const_defined?(:EM) && EM.reactor_running?
  end
  
end

puts "Main, evented ? #{evented?().inspect}"

EM.run_block do
  puts "Loop, evented ? #{evented?().inspect}"  
end