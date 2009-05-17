require 'fcntl'

Signal.trap( "IO" ) do
  puts 'io'
end

fd = IO::sysopen('/tmp/tempfile', Fcntl::O_WRONLY | Fcntl::O_CREAT )
f = IO.open(fd)
m = f.fcntl(Fcntl::F_GETFL, 0)
f.fcntl( Fcntl::F_SETFL, Fcntl::O_NONBLOCK | 64 | m )
f.syswrite("TEMP DATA")
f.close