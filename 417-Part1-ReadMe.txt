Project 3: Overlay Routing
Part 1
 
CMSC 417: Computer Networking
Spring 2015
Instructor: Ashok K. Agrawala
 
Team Members
Dylan Zingler
Sarthi Andley
Triana McCorkle


How to run
1. Open the terminal of the node from CORE
2. cd into the directory of the submission
3. Run the shell script by “./test.sh”


Implementation
Our node.rb file consists of three subsections. We used many helper methods throughout the project to assist our work.
1. Find the neighbors for the node
This was done by parsing the nta and atl textfiles. Pattern matching functionality of ruby made it efficient.
   1. Get the hostname of the node running the file
      1. Run ifconfig
      2. Get the inet addr IP
      3. Get the hostname corresponding to that IP in nta file
   1. Get the links connected to the hostname
      1. Get the IP addresses connected to the hostname from the nta file
      2. Get the links corresponding to those addresses from the atl file
   1. Get the names of the nodes with the links from above step
      1. Parse through nta to get the name of node from the link
n
1. Compute the graph matrix using Link state routing
   1. First a ruby class (Neighbor_Packet) for this specific node is instantiated which contains, the nodes hostname, IP address, neighbors, and matrix
   2. A TCP server is started on a specific port for managing network topology, every client that connects will receive a print out of this nodes Neighbor_Packet
   3. Next a client is open for every neighbor of that node to their IP using the same previous port
   4. When a client receives a Neighbor_Packet, it checks to see if the matrixes are the same, if the matrices in the packets are not equal then the information from both is merged into a single packet with a matrix representing all connections in both packets. This new packet is now this nodes packet. The client connection process continues until the Neighbor_Packet of its neighbor is the same is its own. 


1. Run Dijkstra's algorithm to find the shortest path
Dijkstra's algorithm could have been substituted for any other algorithm that also finds the shortest path between two nodes in a graph. We used Dijkstra's algorithm as it is still a commonly accepted way to do this. It was implemented by a breadth first search and priority queue. For each node, the shortest path was computed using Dijkstra's algorithm allowing packets of the network to be sent to their destinations along paths with minimal costs and hops.


Output
The program dumps the results in a csv file (in the same directory) prefixed with the hostname of the node (for example node “n1” will produce “n1-dijsktra.csv”). This is basically the result from Dijkstra's algorithm. The output file consists of a matrix with destination and distance columns. It computes the shortest distance from the source node to all of its neighbors. This is used to determine the shortest path between two nodes which the packet will take.