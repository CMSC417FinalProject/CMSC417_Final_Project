=begin
	
PROJECT 3
Members:
Sarthi Andley
Dylan
Triana
=end


#Useful variables and methos
$nodes_to_addrs = File.readlines('nodes-to-addrs.txt')
$addrs_to_links = File.readlines('addrs-to-links.txt')

#Method to returns the node connected with input addr
def ip_to_node ip
	#Get the lines from ntr where node is with that IP
	node_ip_lines = $nodes_to_addrs.select{ |line| line =~ /#{ip}/ }

	if (node_ip_lines[0] == nil)
		puts "ERROR: Could not find the IP = #{ip} in the nodes_to_addrs.txt file"
	end

	#Remove the IP and whitespace from string
	node_ip_lines[0].split[0...1].join(' ')
end

def destination_of_addr input
	#Get the lines from atr with input
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



=begin
Section 2: TCP SERVER, packet exchange and final topology cost matrix
TO DO - DYLAN
=end


=begin
Section 3: Dikstra's implementation
#TO DO - TRIANA
=end