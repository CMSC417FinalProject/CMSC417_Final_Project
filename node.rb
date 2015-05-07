#ruby node.rb <nta> <atl> <config_file>
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
require 'fileutils'
#require 'json'


#CONFIG FILE - PARAMETERS
$config_file = File.readlines(ARGV[2])

#defaults
$max_packet_size = 255
$cost_path = "costs.txt"
$routing_interval = 200
$routing_table_path = "Routing_tables"
$dump_interval = 200

#Read from file
$config_file.each_with_index do |line, index|
  line.delete!("\n")
  case index
  when 0
    $max_packet_size = line.to_i
  when 1
    $cost_path = line
  when 2
    $routing_interval = line.to_i
  when 3
    $routing_table_path = line
  when 4
    $dump_interval = line.to_i
  else
    puts "Error: Config file is ignoring -- #{line}"
  end
end


#Useful variables and methos
$nodes_to_addrs = File.readlines(ARGV[0])
$addrs_to_links = File.readlines(ARGV[1])
$costs = (File.readlines($cost_path, 'r'))
$sequence_number = 0
$server_port = 2000
#$costs = $costs[0]



class Matrix
  def []=(row, column, value)
    @rows[row][column] = value
  end
end

#Method to returns the node connected with input addr

def get_cost_from_ip (ip1,ip2)
  #get the cost betweent the 2 ips reading from the text file produced by gen_weights
  ip_substring = ip1.concat(",").concat(ip2)
  cost_lines = $costs.select{ |line| line =~ /^#{ip_substring}/}
  if (cost_lines[0] == nil)
    return 0
  end
  c = cost_lines[0].split(',')
  $sequence_number = c[3].to_i
  return c[2].to_i
end

#10.0.11.20,10.0.11.21,2,44
#print "=Cost: "
#puts get_cost("10.0.11.20", "10.0.11.21")

def ip_to_node ip
  #Get the lines from nta where node is with that IP
  node_ip_lines = $nodes_to_addrs.select{ |line| line =~ /#{ip}/ }

  if (node_ip_lines[0] == nil)
    puts "ERROR: Could not find the IP = #{ip} in the nodes_to_addrs.txt file"
  end

  #Remove the IP and whitespace from string
  node_ip_lines[0].split[0...1].join(' ')
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


def get_cost(n_s, n_d)
  nodes_to_addrs2 = File.readlines(ARGV[0])
  
  n_s_ip_lines = nodes_to_addrs2.select{ |line| line =~ /#{n_s}\s/ }
  n_s_ip = []
  n_s_ip_lines.each {|line|
    n_s_ip.push line.split[1..2].join('\t')
  }


  n_d_ip_lines = nodes_to_addrs2.select { |line| line =~ /#{n_d}\s/ }



  n_d_ip = []
  n_d_ip_lines.each {|line|
    n_d_ip.push line.split[1..2].join('\t')
  }

  ip1 = ""
  ip2 = ""
  n_s_ip.each{ |s_ip| 
    n_d_ip.each{ |d_ip|
      if ((destination_of_addr s_ip) == d_ip)
        #puts "CONNECTION WITH " + d_ip
        ip1.concat("#{s_ip}")
        ip2.concat("#{d_ip}")
      end
    }
  }
  get_cost_from_ip(ip1, ip2)
end


=begin
Retrieve neighbors of the node
(1) Get the hostname
(2) Get links connected to hostname
(3) Get the node_names of those links 
=end


nta = File.readlines(ARGV[0])
$list_of_nodes = []
nta.each{ |line| 
    n = line.split[0...1].join(' ')
    $list_of_nodes.push(n)
}
$list_of_nodes = ($list_of_nodes.uniq).sort

num_of_nodes = $list_of_nodes.count

cost = Array.new(num_of_nodes) { Array.new(num_of_nodes) {nil}}
for i in 0..(num_of_nodes-1)
  n_s = $list_of_nodes[i]
   for j in 0..(num_of_nodes-1)
    n_d = $list_of_nodes[j]
    c = get_cost(n_s, n_d)
    cost[i][j] = c 
   end
end
puts "=Sequence number of cost file used: #{$sequence_number}"

#puts "Cost Matrix: "
#puts cost.inspect
=begin
print "Connections n1 & n2 : "
puts get_cost("n1","n2").inspect
puts "end"
=end
#puts cost.inspect
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
$host_index = $list_of_nodes.index(hostname)
puts "=Hostname: #{hostname}"
print "=Node list : "
puts $list_of_nodes.inspect

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


#puts "=Neighbors: "
#puts neighbors

=begin
puts "Neighbors Connections"
neighbors.each{ |n|
  puts "hostname = " + hostname + " Neighbor = " + n
  right_ip = conn_ip(hostname,n)
  puts "\nIP to open with #{n} is "
  puts right_ip

}
=end

=begin
Section 2: TCP SERVER, packet exchange and final topology cost matrix
TO DO - DYLAN
###########################################################################################################


class Node
  
  attr_reader :self_neighbor_packet
  attr_reader :mutex
  attr_reader :neighbor_packets
  attr_reader :sequence_number
   
  def initialize(np)
    @self_neighbor_packet = np
    @mutex = Mutex.new
    @neighbor_packets = []
    @sequence_number = -1
    
    
    
    
    update_neighbor_packets
  end
  
  def merge_neighbor_packets
    # Merges all neighbor information
    @neighbor_packets.each { |x|    
        puts "Matrix Before Merge with " + x.h_name + " :" + @self_neighbor_packet.neighbor_matrix.inspect  
        @self_neighbor_packet = matrix_merger(@self_neighbor_packet, x)             
        puts "Matrix After Merge :" + @self_neighbor_packet.neighbor_matrix.inspect   
    }    
  end
  
  def update_neighbor_packets
    # Thread Safe get of all the neighbor_packets
    
    client_threads = []
    @neighbor_packets = []
    
    @self_neighbor_packet.n_bors.each { |n|
    puts "NEIGHBORS of your packet: " + @self_neighbor_packet.n_bors.to_s
      
      puts "WOWOWOWO" + n.to_s
      
      s = Thread.new {
        received_packet = false
        
        while not received_packet
          
          # Try Connection 
          begin
            message = ""
        
            puts "IM GOING TO HOST:" + n
            neighbor_ip = conn_ip(@self_neighbor_packet.h_name,n)
            port = 2000                     
            puts neighbor_ip.inspect
           
            a = TCPSocket.open(neighbor_ip, port)
           
            while line = a.gets
              puts line.chop
              message += line
            end
            a.close
            
            neighbor_packet = net_packet_builder message
            
            @mutex.synchronize {
              puts "Neighbor Packets: " + @neighbor_packets.inspect
              @neighbor_packets << neighbor_packet
              puts "Neighbor Packets: " + @neighbor_packets.to_s
            }
           
            received_packet = true
            
          rescue SystemCallError            
            puts "CONNECTION ERROR: Could not Connect to ADDRESS " + n
            sleep(1)
          end
          
          
        end               
        
      }
      
      client_threads << s
      
      client_threads.each {|c|
        c.join        
      }
      
      puts "ALL Neighbor Packets Received"
      
      
    }

  end
  
  def check_matrices
    # Checks if all matrices are the same    
    neighbor_same = true # assume neighbors are the same
    
    @neighbor_packets.each {|np_2|      
      
      puts "CHECKING MATRICIES ####################################"
      puts "SELF MATRIX:" + @self_neighbor_packet.neighbor_matrix.to_s
      puts "NEIGHBOR MATRIX:" + np_2.neighbor_matrix.to_s
      
      if @self_neighbor_packet.neighbor_matrix != np_2.neighbor_matrix
        neighbor_same = false
        break
      end      
    }
      
    return neighbor_same      
  end
  
  
end



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
      return np_1
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

#puts "WHERE HERe"
#puts neighbors.inspect
#puts node_net_packet.to_s


#-------------------------------------------------------------------------------------------------
# Generating Network Topology
#-------------------------------------------------------------------------------------------------
neighbors = neighbors.sort
node_net_packet = Neighbor_Packet.new(neighbors,hostname,ip,nil, nil)

puts "HERE IS YOUR PACKET NOW"
puts node_net_packet.to_s

# TCP Server (***GET ME SOME NEIGHBORS (-:   )
server = TCPServer.open($server_port)   # Socket to listen on port 2000

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


node = Node.new(node_net_packet)

node.update_neighbor_packets

node.merge_neighbor_packets

node_net_packet = node.self_neighbor_packet

while node.check_matrices != true
  
  
  node.update_neighbor_packets

  node.merge_neighbor_packets
  
  node_net_packet = node.self_neighbor_packet

  
  sleep(1)
  
end

puts "MATRICES SHOULD BE EQUAL NOW"
puts node.self_neighbor_packet


#-------------------------------------------------------------------------------------------------
=end



=begin

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
      
      
      if matrix_merger(node_net_packet, neighbor_packet) == node_net_packet
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

=end

=begin
Section 3: Dikstra's implementation
#TO DO - TRIANA
#########################################################################################################
=end

=begin
node_list_hash = Hash[node_net_packet.nodes_list.map.with_index.to_a]
$host_index = node_list_hash[node_net_packet.h_name]

puts "ENDING OF PROGRAM"
puts $host_index
puts node_net_packet.neighbor_matrix.to_a.inspect
puts Dir.pwd

graph = node_net_packet.neighbor_matrix.to_a
=end

graph = cost
#NUM_NODES = graph.length
NUM_NODES = num_of_nodes
#HOST = $host_index
PositiveInfinity = +1.0/0.0 

def min_dist(dist, shortest)
  min = PositiveInfinity
  min_index = -1
  
  for n in 0..NUM_NODES - 1
    if((shortest[n] == false) && (dist[n] <= min))
      min = dist[n]
      min_index = n
    end
  end
    
  return min_index
end


def dijkstra_printer(dist, prev)
  #csv file with desrtination node, cost, previous node
  str = ""
  for i in 0..NUM_NODES-1
    if (i != $host_index)
      n_d = $list_of_nodes[i]
      n_p = $list_of_nodes[(prev[i])]
      str += "#{n_d},#{dist[i]},#{n_p}\n"
    end
  end
  return str
end


def dijkstra(graph, src)
  dist = []
  shortest = []
  prev = []
  
  for i in 0..(NUM_NODES-1)
    dist[i] = PositiveInfinity
    shortest[i] = false
    prev[i] = nil
  end

  dist[src] = 0
  prev[src] = nil

  for count in 0..NUM_NODES-2
    u = min_dist(dist, shortest);
    shortest[u] = true;
    for n in 0..NUM_NODES-1
      if (!shortest[n] && graph[u][n] != 0 && dist[u] != PositiveInfinity && (dist[u] + graph[u][n]) < dist[n])
        dist[n] = dist[u] + graph[u][n]
        prev[n] = u
      end
    end
  end

  return dijkstra_printer(dist, prev)
end

#dirname = File.dirname('Dijksta_files')

FileUtils.mkdir_p('Dijksta_files')
 
File.open('Dijksta_files/'+hostname+'_dijkstra.csv', 'w+') { |file| file.write(dijkstra(graph, $host_index)) }

$dijkstra_read = File.readlines('Dijksta_files/'+hostname+'_dijkstra.csv', 'r')
$dijkstra_result = $dijkstra_read[0].split("\n")

$path = Array.new(num_of_nodes){[]}
#$path[$host_index] = [hostname]

$hostname = hostname

#Recursive helper function to find the path using previous nodes from Dijstra results
def prev_node_finder(n_s, i)
      path_line = $dijkstra_result.select{ |line| line =~ /^#{n_s}/}
      path_line_array = []
      if (path_line[0] == nil)
         return
      else
        path_line_array = path_line[0].split(',')
      end
      prev_node = path_line_array[2]

      if (prev_node == $hostname)
        index = $list_of_nodes.index($hostname)
        $path[index] = [[$hostname]]
        return
      end
      $path[i].push(prev_node)
      prev_node_finder(prev_node,i)
      #puts "Previous node of #{n_d} is #{prev_node}"
end

#Create shortest path from hostname to every node in the network
for i in 0..(num_of_nodes-1)
  n_s = $list_of_nodes[i]
    n_s = $list_of_nodes[i]
    prev_node_finder(n_s,i)
    $path[i].reverse!
    $path[i].push(n_s)
end


print "=Shortest Path: "
puts $path.inspect

#Making routing tables

FileUtils.mkdir_p($routing_table_path) 
routing = File.open($routing_table_path+'/'+hostname+'_routing.csv', 'w+')
$list_of_nodes.each_with_index{|n_d, index|
  next_hop = $path[index][1]
  dijsktra_line = $dijkstra_result.select{ |line| line =~ /^#{n_d}/}
  if (dijsktra_line[0] == nil)
    routing_cost = 0
  else
    routing_cost = (dijsktra_line[0].split(','))[1]
  end
  line = "#{hostname},#{n_d},#{routing_cost},#{next_hop}"
  routing.write(line+"\n")
}
routing.close

class Message
  
  attr_reader :data_id
  attr_reader :type
  attr_reader :sequence
  attr_reader :path
  attr_reader :data
  attr_reader :data_size
  attr_reader :original_path

  def initialize(data_id, type, sequence, path, data, data_size, original_path)
    @data_id = data_id
    @type = type
    @path = path
    @sequence = sequence
    @data = data
    @data_size = data_size
    @original_path = original_path
  end
    
  
  def to_s
    ret = ""
    ret += data_id.to_s
    ret += "~"
    ret += type
    ret += "~"
    ret += sequence.to_s
    ret += "~"
    path_ret = path.inspect.delete("[").delete("]").delete("\"").delete(" ")
    ret += path_ret
    ret += "~"
    ret += data
    ret += "~"
    ret += data_size.to_s
    ret += "~"
    path_ret = original_path.inspect.delete("[").delete("]").delete("\"").delete(" ")
    ret += path_ret
  end

end
def message_builder msg
    # When a Client recives a message, this method creates Neighbor_Packet object

    message_arr = msg.split("~")
    data_id = message_arr[0]
    type = message_arr[1]
    sequence = message_arr[2]
    path = message_arr[3].split(",")
    data = message_arr[4]
    data_size = message_arr[5]
    original_path = message_arr[6]
    return Message.new(data_id, type, sequence, path, data, data_size, original_path)
end




STDOUT.flush
puts "\nPlease enter nature of node (SERVER/CLIENT)"
nature = $stdin.gets.chomp


def server(data, dest_path, type)
        data_size = data.length

        if (data_size > $max_packet_size)
          puts "MESSAGE DATA IS TOO BIG. Please develop fragmentation"
          #FRAGMENTATION HERE
        end

        dest = dest_path[0]   #NEXT HOP NODE

        message = Message.new(1, type, 1, dest_path, data, data_size, dest_path)
      

        # Actual TCP Server
        server = TCPServer.open($server_port)   # Socket to listen on port 2000
        s = Thread.new {
          loop {    
            Thread.start(server.accept) do |client|
              puts "SENT: #{message.to_s}"
              client.puts(message.to_s) # Send the time to the client    
              #puts "Closing the connection. Bye!"
              client.close                # Disconnect from the client
            end
          }
      }

end
#CLIENT

#neighbors

neighbors_ip = []
neighbors.each{ |n|
  neighbors_ip.push(conn_ip(hostname, n))
}


if (nature == "SERVER")
  puts "\nEnter the command"
  c = $stdin.gets.chomp
  cmd = split(" ")

  if(cmd[0] == "SENDMSG")

    cmd_data = c.split("\"")
    data = cmd_data[1]
    dest_node = ip_to_node(cmd[1])
    #data = cmd[2].delete("\"")

    puts "\nPlease enter type of data"
    type = $stdin.gets.chomp
    #puts "\nPlease enter the data of the message: "
    #data = $stdin.gets.chomp
    #puts "\nPlease enter the destination node: "
    #dest_node = $stdin.gets.chomp
    
    dest_index = $list_of_nodes.index(dest_node)
    dest_path = $path[dest_index]
    dest_path.shift
    server(data,dest_path,type)
  elsif (cmd[0] == "PING")
    dst = cmd[1]
    numpings = cmd[2]
    delay = cmd[3]
    type = "PING"

    puts "TO DO: Ping #{dst} with delay = #{delay}, #{numpings} times"
  elsif (cmd[0] == "TRACEROUTE")
    dst = cmd[1]
    puts "TO DO: TRACEROUTE to #{dst}"
  else
    puts "INCORRECT COMMAND"
  end
    
end


if (nature == "CLIENT")

    #server_ip = conn_ip("n2", "n1")
    #puts "Server's IP is #{server_ip}"
    neighbors_ip.each{ |ip|
        begin
          s = TCPSocket.open(ip, $server_port)
          while line = s.gets   # Read lines from the socket
            msg_str = line.chop      # And print with platform line terminator
            msg = message_builder(msg_str)
            
            if (msg.path[0] != nil && msg.path[0] == hostname)
              if(msg.path[1] != nil)
                data_path = msg.path.drop(1)
                #print "Sending it forward along the path = "
                #puts data_path.inspect
                server(msg.data, data_path, msg.type)
              else
                #CHECK FOR TYPE
                if(msg.type == "PING")
                  path = msg.original_path.reverse
                  print "new path is "
                  puts path.inspect
                  puts "PING RECEIVED from #{path[-1]}"
                end
                puts "Data: #{msg.data}"
                puts "Message: #{msg.to_s}"
              end
            end

            #elsif (msg.path[0] != nil && msg.path[0] != hostname)
             # puts "FYI We need to send this message forward to #{msg.path[0]}"
            #end
          end
          s.close
        rescue SystemCallError            
                  #puts "No connection from #{ip_to_node(ip)}"
        end
                         # Close the socket when done
  
      }
end

sleep(60)
puts "END OF PROGRAM"