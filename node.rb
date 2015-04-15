=begin
	
PROJECT 3
Members:
Sarthi
Dylan
Triana
=end



puts "Section 1: Retrieve the neighbors of the nodes"

=begin
Trying to retrieve neighbors -SA
=end

ifconfig = `ifconfig`
#puts ifconfig
ip = ifconfig.match(/eth0/)[0]
puts ip
puts "End of Section 1"