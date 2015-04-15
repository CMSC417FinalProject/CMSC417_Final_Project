=begin
	
PROJECT 3
Members:
Sarthi
Dylan
Triana
=end


#Useful Variables
nodes_to_addrs = File.readlines('nodes-to-addrs.txt')
addrs_to_links = File.readlines('addrs-to-links.txt')



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

#Get the line from ntr where node is with that IP
node_ip_line = nodes_to_addrs.select{ |line| line =~ /#{ip}/ }
if (node_ip_line[0] == nil)
	puts "ERROR: Could not find the IP in the nodes_to_addrs.txt file"
end
#Remove the IP from string
hostname = node_ip_line[0].split[0...1].join(' ')

#Got the hostname
puts "=Hostname: #{hostname}"

puts "\n\n"


=begin
Section 2: TCP SERVER, packet exchange and final topology cost matrix
TO DO - DYLAN
=end


=begin
Section 3: Dikstra's implementation
#TO DO - TRIANA
=end
