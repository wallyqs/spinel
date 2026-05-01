require 'socket'

# Spawn a one-shot line-echo peer in the background.
# Both CRuby and spinel will fork this same peer via system().
PORT = 19876
system(%Q{ruby -rsocket -e 'srv = TCPServer.new(#{PORT}); c = srv.accept; while line = c.gets; c.write(line); end; c.close; srv.close' &})
system("sleep 1")

TCPSocket.open("127.0.0.1", PORT) do |s|
  s.write("hello\n")
  line = s.gets
  puts line
  s.write("world\n")
  line = s.gets
  puts line
end

# Reap the background peer (may already be gone).
system("wait 2>/dev/null")
puts "done"
