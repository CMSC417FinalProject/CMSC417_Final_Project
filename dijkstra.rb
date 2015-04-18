NUM_NODES = ARGV[1]

def min_dist(dist, shortest)
  min = Float::INFINITY
  min_index
  
  for n in 0..NUM_NODES - 1
    if(shortest[n] == false && dist[n] <= min)
      min = dist[n], min_index = n
    end
  end
    
  return min_index
end


def print(dist, n)
  puts "Vertex  Distance from source\n"
  for i in 0..NUM_NODES-1
    puts i,"\t\t",dist[i],"\n"
  end
end


def dijkstra(graph, src)
  dist[NUM_NODES]
  shortest[NUM_NODES]
     
  for i in 0..NUM_NODES-1
    dist[i] = Float::INFINITY, shortest[i] = false
  end

  dist[src] = 0

  for count in 0..NUM_NODES-2
    u = min_dist(dist, shortest);
    shortest[u] = true;

    for n in 0..NUM_NODES-1
      if (!shortest[n] && graph[u][n] && dist[u] != INT_MAX && (dist[u] + graph[u][n]) < dist[n])
        dist[n] = dist[u] + graph[u][n]
      end
    end
  end
        
    printSolution(dist, NUM_NODES);
end

def main()
  int graph[NUM_NODES][NUM_NODES] = [[0, 4, 0, 0, 0, 0, 0, 8, 0],
                                      [4, 0, 8, 0, 0, 0, 0, 11, 0],
                                      [0, 8, 0, 7, 0, 4, 0, 0, 2],
                                      [0, 0, 7, 0, 9, 14, 0, 0, 0],
                                      [0, 0, 0, 9, 0, 10, 0, 0, 0],
                                      [0, 0, 4, 0, 10, 0, 2, 0, 0],
                                      [0, 0, 0, 14, 0, 2, 0, 1, 6],
                                      [8, 11, 0, 0, 0, 0, 1, 0, 7],
                                      [0, 0, 2, 0, 0, 0, 6, 7, 0]]
 
    dijkstra(graph, 0)
 
    return 0
end
