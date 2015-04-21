=begin
  
PROJECT 3
Members:
Sarthi Andley
Dylan Zingler
Triana M.
=end

require 'socket'
require 'matrix'
require 'set'
require 'json'

# Globals
server_port = 2000

#Useful variables and methos
$nodes_to_addrs = File.readlines(ARGV[0])
$addrs_to_links = File.readlines(ARGV[1])

class Matrix
  def []=(row, column, value)
    @rows[row][column] = value
  end
end

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
  #puts "\nn_s = " + n_s + " n_d = " + n_d
  
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
  @n_bors = []
  @h_name = ""
  @i_p = nil
  
  attr_reader :n_bors
  attr_reader :h_name
  attr_reader :i_p
  attr_reader :nodes_list
  attr_reader :neighbor_matrix
  
  def initialize(n_bors, h_name, i_p, neighbor_matrix, node_l)
    @n_bors = n_bors
    @h_name = h_name
    @i_p = i_p.clone
    
    if node_l == nil
      @nodes_list = []    
      @nodes_list = @n_bors.clone
      @nodes_list << @h_name
      @nodes_list.sort!
    else
      @nodes_list = node_l
    end
    
    if neighbor_matrix == nil
      @neighbor_matrix = matrix_builder(@h_name,@nodes_list)       
    else
      @neighbor_matrix = neighbor_matrix.clone
    end  
               
  end
    
  
  def to_s
    string = ""
    @n_bors.each {|n| string += n + "\t"}
    string += "\n"
    string += @h_name + "\n"
    string += @i_p + "\n"
              
    @nodes_list.each {|neigh| string += neigh + "\t"}
    string += "\n"   
    @neighbor_matrix.row_vectors.each {|row| 
      arr = []
      row.collect {|x| arr << x}
      
     
      arr.each {|x| string +=  x.to_s + "\t"}
      string +=  "\n"
      
      }
    return string
  end
  
end


def net_packet_builder message
  # When a Client recives a message, this method creates Neighbor_Packet object
  message_arr = message.split("\n")
  
  nbors = message_arr[0].split("\t")
  hname = message_arr[1]
  i__p = message_arr[2]
  headder = message_arr[3].split("\t")
  
  matrix = []
  message_arr[4..-1].each {|line| 
    
    vals = line.split("\t")
    v = []
    vals.each {|x| v << x.to_i}
    matrix << v
    
    }
  #puts matrix.inspect
  n_p = Neighbor_Packet.new(nbors,hname,i__p,Matrix.rows(matrix), headder)
  
  matrix = nil
  return n_p
  
end



def matrix_builder(h_name, n_list)  
  # Creates a matrix from a list of neighbors
  mat = Matrix.build(n_list.length, n_list.length) {|row, col| 0 }
  #puts "HOSTNAME INDEX: " + n_list.index(h_name)
  
  hash = Hash[n_list.map.with_index.to_a]
  #puts "HELLOEHEhEH" + hash[h_name].to_s
  
  # set all neighbors to one
  mat.each_with_index do |e, row, col|
    if row == hash[h_name] and col != hash[h_name]
      mat[row,col] = 1
    elsif col == hash[h_name] and row != hash[h_name]
      mat[row,col] = 1
    else
      mat[row,col] = 0
    end
  
  end
  
  return mat
end

def matrix_merger(np_1, np_2)
  # Merges 2 packets matrices 
  
  #MATRICES TO MERGE
  #Matrix[[0, 1, 1], [1, 0, 0], [1, 0, 0]]
  #Matrix[[0, 1, 0, 0], [1, 0, 1, 1], [0, 1, 0, 0], [0, 1, 0, 0]]
  
  
  #puts np_1.instance_variable_get(:@node_list).inspect
  #puts np_2.instance_variable_get(:@node_list).inspect
  
  #puts np_1.to_s
  #puts np_2.to_s  
  
  #puts "HERE ARE THE NEIGHBORS: " + np_1.nodes_list.inspect
  
  nD = (np_1.nodes_list + np_2.nodes_list).to_set.to_a
  puts "THIS IS Nd: " + nD.inspect
  
  # Check if matrixes are the same
  if np_1.nodes_list == np_2.nodes_list
    # Ensure that every entry in the matrix is the same
      puts "MATRICES TO MERGE"
      puts np_2.nodes_list.inspect
      puts np_2.neighbor_matrix.inspect
      puts np_1.nodes_list.inspect
      puts np_1.neighbor_matrix.inspect
    
    if np_1.neighbor_matrix == np_2.neighbor_matrix
      return "matrices are equal"
    else
      n_mat = np_1.neighbor_matrix.clone
      
      # If the value is 0 then overwrite it with np_2's value
      n_mat.each_with_index {|v, x, y| 
        if v == 0
          n_mat[x,y] = np_2.neighbor_matrix[x,y]
        end
        
        }
      
      puts "MERGED MATRIX"
      puts n_mat.inspect
      return Neighbor_Packet.new(np_1.n_bors,np_1.h_name,np_1.i_p,n_mat, nD)
            
    end
    
  else
    
    
    puts "MATRICES TO MERGE"
    puts np_2.nodes_list.inspect
    puts np_2.neighbor_matrix.inspect
    puts np_1.nodes_list.inspect
    puts np_1.neighbor_matrix.inspect
    
    n_mat = Matrix.zero(nD.length)
      
    # Copying of B (np_2) into N (new Network_Packet)
    n2_index_in_nD = [] # Hostname mappings B to N
    np_2.nodes_list.each {|n2_hostname| 
      nD_hash = Hash[nD.map.with_index.to_a] 
      #nD.find_index
      n2_index_in_nD << nD_hash[n2_hostname]
      
      }
    
    puts "KEY MAPPINGS: N2" + Hash[n2_index_in_nD.map.with_index.to_a].inspect
    
    n2_index_in_nD.each_with_index {|x,i| 
      n2_index_in_nD.each_with_index {|y,j|
        n_mat[x,y] = np_2.neighbor_matrix[i,j]
      }
    
    puts "B MATRIX IS NOW COPIED INTO N MATRIX"
    puts n_mat.inspect
      
    }
    
    # Copying of A (np_1) into N (new Network_Packet)
    n1_index_in_nD = [] # Hostname mappings A to N
    np_1.nodes_list.each {|n1_hostname|
      nD_hash = Hash[nD.map.with_index.to_a] 
      
      n1_index_in_nD << nD_hash[n1_hostname]
      }
      
    puts "KEY MAPPINGS N1: " + Hash[n1_index_in_nD.map.with_index.to_a].inspect  
    n1_index_in_nD.each_with_index {|x,i|
      n1_index_in_nD.each_with_index {|y,j|
        n_mat[x,y] = np_1.neighbor_matrix[i,j]          
        }
      }    
    
    puts "MERGED MATRIX"
    puts n_mat.inspect
    return Neighbor_Packet.new(np_1.n_bors,np_1.h_name,np_1.i_p,n_mat, nD)
  end
  
end

# Network Packet for THIS NODE
#matrix_builder neighbors

node_net_packet = Neighbor_Packet.new(neighbors,hostname,ip,nil, nil)
#puts "WHERE HERe"
#puts neighbors.inspect
#puts node_net_packet.to_s



# TCP Server (***GET ME SOME NEIGHBORS (-:   )
server = TCPServer.open(server_port)   # Socket to listen on port 2000

s = Thread.new {
loop {                          # Servers run forever
  Thread.start(server.accept) do |client|
    puts "CONNECTION MADE TO SERVER"
    client.puts(node_net_packet.to_s) # Send the time to the client    
    #client.puts "Closing the connection. Bye!"
    client.close                # Disconnect from the client
  end
}

}



# TCP Packet Retrival from other Neighbors
  
message = ""

matrices_equal = false

while matrices_equal != true
  begin 
    
    count = 0
    
    neighbors.each {|n|
      
      count += 1
      
      if n == hostname
        next
      end 
      

      message = ""
        
      puts "IM GOING TO HOST:" + n
      neighbor_ip = conn_ip(hostname,n)
      port = 2000
      
      #puts neighbor_ip.to_s + " <--IP:Port -->" +  port.to_s
      puts neighbor_ip.inspect
      
      s = TCPSocket.open(neighbor_ip, port)
      
      puts "LINE OUTPUT"
      while line = s.gets   # Read lines from the socket
        puts line.chop      # And print with platform line terminator
        message += line
      end
      s.close               # Close the socket when done
      
      neighbor_packet = net_packet_builder message
      #puts neighbor_packet.to_s
      
      #puts "THIS IS THE NEW PACKET"
      
      
      if matrix_merger(node_net_packet, neighbor_packet) == "matrices are equal"
        matrices_equal = true
        puts "MATRICES ARE EQUAL!!!"
      else
        node_net_packet = matrix_merger(node_net_packet, neighbor_packet)
      end          
      puts node_net_packet.to_s
           
      #node_net_packet = new_packet
      if matrices_equal == false
        break
      end 
        
    
    } # End of neighbors
    
    if count == neighbors.length
      
    end
  
  rescue SystemCallError
   
   puts "CONNECTION ERROR: PLEASE HOLD WHILE TRYING TO CONNECT"
   sleep(1)
  end
  sleep(1)
end



=begin
Section 3: Dikstra's implementation
#TO DO - TRIANA
=end


node_list_hash = Hash[node_net_packet.nodes_list.map.with_index.to_a]
host_index = node_list_hash[node_net_packet.h_name]

puts "ENDING OF PROGRAM"
puts host_index
puts node_net_packet.neighbor_matrix.to_a.inspect
puts Dir.pwd

graph = node_net_packet.neighbor_matrix.to_a
NUM_NODES = graph.length
HOST = host_index


def min_dist(dist, shortest)
  min = Float::INFINITY
  min_index = -1
  
  for n in 0..NUM_NODES - 1
    if((shortest[n] == false) && (dist[n] <= min))
      min = dist[n]
      min_index = n
    end
  end
    
  return min_index
end


def print(dist, n)
  str = "Destination  Distance\n"
  for i in 0..NUM_NODES-1
    str += "    #{i}\t\t#{dist[i]}\n"
  end
  return str
end


def dijkstra(graph, src)
  dist = []
  shortest = []
  
  for i in 0..(NUM_NODES-1)
    dist[i] = Float::INFINITY
    shortest[i] = false
  end

  dist[src] = 0

  for count in 0..NUM_NODES-2
    u = min_dist(dist, shortest);
    shortest[u] = true;

    for n in 0..NUM_NODES-1
      if (!shortest[n] && graph[u][n] != 0 && dist[u] != Float::INFINITY && (dist[u] + graph[u][n]) < dist[n])
        dist[n] = dist[u] + graph[u][n]
      end
    end
  end

  return print(dist, NUM_NODES)
end

File.open(node_net_packet.h_name.to_s+'_dijkstra.csv', 'w') { |file| file.write(dijkstra(graph, 0)) }

loop {
  
}
