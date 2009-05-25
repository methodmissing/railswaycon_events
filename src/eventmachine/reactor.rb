require 'rubygems'
require 'eventmachine'

EM.run do
  sleep 5
  EM.stop
end