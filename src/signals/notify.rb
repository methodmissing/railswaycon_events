require 'fcntl'

Signal.trap( "IO" ) do
  puts 'io'
end

module Fcntl
  F_SETOWN = 6
  O_ASYNC = 0x0040  
end

fd = IO::sysopen('/tmp/tempfile', Fcntl::O_WRONLY | Fcntl::O_CREAT )
f = IO.open(fd)
m = f.fcntl(Fcntl::F_GETFL, 0)
#f.fcntl( Fcntl::F_SETOWN, Process.pid )
f.fcntl( Fcntl::F_SETFL, Fcntl::O_RDWR | Fcntl::O_NONBLOCK | Fcntl::O_ASYNC | m )
f.syswrite("TEMP DATA")
f.close
sleep