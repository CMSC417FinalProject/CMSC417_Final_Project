=begin
Author: Dylan Zingler 
Purpose: Project 3 CMSC417

Usage:
$ ruby tcp-client.rb 

Citations:
http://www.tutorialspoint.com/ruby/ruby_socket_programming.htm

=end

require 'socket'      # Sockets are in standard library

hostname = 'localhost'
port = 2000

s = TCPSocket.open(hostname, port)

while line = s.gets   # Read lines from the socket
  puts line.chop      # And print with platform line terminator
end
s.close               # Close the socket when done

