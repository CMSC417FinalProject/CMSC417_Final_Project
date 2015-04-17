# Members
Sarthi Andley
Dylan Zingler



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

### File Input and Output
```ruby
File.open('YOUR-FILENAME-HERE.txt', 'r') do |f1|  
  while line = f1.gets  
    puts line  
  end  
end
```
- Notice that the object returned from File.Open is assigned to f1, then each line is 'gotten' from the file printed and then discarded

```ruby
File.open('NAME-OF-NEWFILE-HERE.txt', 'w') do |f2|  
  # use "\n" for two lines of text  
  f2.puts "Created by Satish\nThank God!"  
end
```

### CSV Files
```ruby
require 'csv'
customers = CSV.read('NAME-OF-CSVFILE.csv')
```
- creates a list of lists of strings



```ruby
```





