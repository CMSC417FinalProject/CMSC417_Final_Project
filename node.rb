=begin
	
PROJECT 3
Members:
Sarthi Andley
Dylan Zingler
Triana M.
=end

require 'socket'

# Globals
server_port = 2000

#Useful variables and methos
$nodes_to_addrs = File.readlines(ARGV[0])
$addrs_to_links = File.readlines(ARGV[1])

#Method to returns the node connected with input addr
def ip_to_node ip
	#Get the lines from nta where node is with that IP
	node_ip_lines = $nodes_to_addrs.select{ |line| line =~ /#{ip}/ }

	if (node_ip_lines[0] == nil)
		puts "ERROR: Could not find the IP = #{ip} in the nodes_to_addrs.txt file"
	end

	#Remove the IP and whitespace from string
	node_ip_lines[0].split[0...1].join(' ')
end

#Method to return the ip connected with input node returns ip of destination
def conn_ip(n_s, n_d)
  nodes_to_addrs2 = File.readlines(ARGV[0])
  puts "\nn_s = " + n_s + " n_d = " + n_d
  
  n_s_ip_lines = nodes_to_addrs2.select{ |line| line =~ /#{n_s}\s/ }
  #puts "\nPRINT N_S LINES"
  #puts n_s_ip_lines


  n_s_ip = []
  n_s_ip_lines.each {|line|
    n_s_ip.push line.split[1..2].join('\t')
  }

  #puts "\nPRINTING N_S IPs"
  #puts n_s_ip
  

  n_d_ip_lines = nodes_to_addrs2.select { |line| line =~ /#{n_d}\s/ }
  #puts "\nPRINTING N_D LINES"
  #puts n_d_ip_lines


  n_d_ip = []
  n_d_ip_lines.each {|line|
    n_d_ip.push line.split[1..2].join('\t')
  }
  #puts "\nPRINTING N_D IPs"
  #puts n_d_ip

  n_s_ip.each{ |s_ip| 
    n_d_ip.each{ |d_ip|
      if ((destination_of_addr s_ip) == d_ip)
        #puts "CONNECTION WITH " + d_ip
        return d_ip
      end
    }
  }
end

def destination_of_addr input
	#Get the lines from atl with input
	destination_lines = $addrs_to_links.select{ |line| line =~ /#{input}/ }

	if (destination_lines[0] == nil)
		puts "ERROR: Could not find the destination link from input adderess in addrs_to_links.txt file"
	end
	#Remove the original address and whitespace from the line 
	first = destination_lines[0].split[0...1].join(' ')
	second = destination_lines[0].split[1...2].join(' ')

	if (first == input)
		return second
	else
		return first
	end
end

=begin
Retrieve neighbors of the node
(1) Get the hostname
(2) Get links connected to hostname
(3) Get the node_names of those links 
=end




#Run ifconfig command
ifconfig = `ifconfig`

#Get the line matching the inet addr (IP)
inet_addr_all = ifconfig.match(/inet addr:(\d)+.(\d).(\d)+.(\d)+/)
if (inet_addr_all == nil)
	puts "ERROR: Could not retrieve inet address for the IP"
end
#Take the first IP from ifcofig
inet_addr = inet_addr_all[0]

#Retrieve just the IP from that string (index 10 onwards)
ip = inet_addr[10..-1]

#Get the hostname from IP
hostname = ip_to_node(ip)

puts "=Hostname: #{hostname}"

#Addresses connected to the hostname
addr_lines = $nodes_to_addrs.select{ |line| line =~ /#{hostname}\s/ }

neighbors = Array.new

#For each address, find the destination node
addr_lines.each{ |line| 
					#Remove the hostname and whitespace from the line
					line.slice! "#{hostname}"
					addr = line.split[0...1].join(' ')
					#puts addr
					#find the destination link of the address
					destination = destination_of_addr(addr)
					#find the node with that link and push it in the array
					neighbors.push ip_to_node(destination)
				}
#Alphaterically sorted array of neighbors
neighbors.sort!


puts "=Neighbors: "
puts neighbors


s1 = "n8"
s2 = "n9"
#right_ip = conn_ip(s1,s2)
#puts "\nIP to open from #{s1} to #{s2} is "
#puts right_ip

puts "Neighbors Connections"
neighbors.each{ |n|
  puts "hostname = " + hostname + " Neighbor = " + n
  right_ip = conn_ip(hostname,n)
  puts "\nIP to open with #{n} is "
  puts right_ip

}


=begin
Section 2: TCP SERVER, packet exchange and final topology cost matrix
TO DO - DYLAN
=end


class Neighbor_Packet
  
  def initialize(neighbors, hostname, ip)
    @neighbors = neighbors
    @hostname = hostname
    @ip = ip
  end
  
end

def matrix builder
  # 
  puts "HELLO"
end

# TCP Server (***GET ME SOME NEIGHBORS (-:   )
server = TCPServer.open(server_port)   # Socket to listen on port 2000

s = Thread.new {
loop {                          # Servers run forever
  Thread.start(server.accept) do |client|
    puts "CONNECTION MADE TO SERVER"
    client.puts(Time.now.ctime) # Send the time to the client
    client.puts "Closing the connection. Bye!"
    client.close                # Disconnect from the client
  end
}

}

# Matrix Definition


# TCP Packet Retrival from other Neighbors
neighbors.each {|n|
    
  puts n
  n_hostname = n
  port = 2000
  
  s = TCPSocket.open(n, port)
  
  while line = s.gets   # Read lines from the socket
    puts line.chop      # And print with platform line terminator
  end
  s.close               # Close the socket when done
  
  

}

loop {
  puts "WELL HELLO THERE"
  
}


=begin
Section 3: Dikstra's implementation
#TO DO - TRIANA
=end