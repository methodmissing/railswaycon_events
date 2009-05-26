require 'rubygems'
require 'eventmachine'

Thread.new do
  EM.run do
    puts 'start machine in a background thread'
  end
end

puts 'main thread'

sleep 1