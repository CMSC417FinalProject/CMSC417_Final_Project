# CMSC417_Final_Project
overlay circuit-switched traffic routing system that uses Link State routing to pass messages between arbitrary nodes.


### TCP Client in Ruby
```ruby
require 'socket'      # Sockets are in standard library

hostname = 'localhost'
port = 2000

s = TCPSocket.open(hostname, port)

while line = s.gets   # Read lines from the socket
  puts line.chop      # And print with platform line terminator
end
s.close               # Close the socket when done

```

### TCP Server in Ruby
```ruby
require 'socket'                # Get sockets from stdlib

server = TCPServer.open(2000)   # Socket to listen on port 2000
loop {                          # Servers run forever
  Thread.start(server.accept) do |client|
    client.puts(Time.now.ctime) # Send the time to the client
	client.puts "Closing the connection. Bye!"
    client.close                # Disconnect from the client
  end
}
```
