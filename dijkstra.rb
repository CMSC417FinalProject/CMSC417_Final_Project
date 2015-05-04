require 'json'

GRAPH = ARGV[0]
graph = JSON.parse(GRAPH)
NUM_NODES = graph.length
HOST = ARGV[1].to_i


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


def print(dist, prev, n)
  str = "Destination  Distance  Previous\n"
  for i in 0..NUM_NODES-1
    str += "\t\t#{i}\t\t\t#{dist[i]}\t\t\t#{prev[i]}\n"
  end
  return str
end


def dijkstra(graph, src)

  dist = []
  shortest = []
  prev = []
  
  for i in 0..(NUM_NODES-1)
    dist[i] = Float::INFINITY
    shortest[i] = false
    prev[i] = nil
  end

  dist[src] = 0
  prev[src] = nil

  for count in 0..NUM_NODES-2
    u = min_dist(dist, shortest);
    shortest[u] = true;

    for n in 0..NUM_NODES-1
      if (!shortest[n] && graph[u][n] != 0 && dist[u] != Float::INFINITY && (dist[u] + graph[u][n]) < dist[n])
        dist[n] = dist[u] + graph[u][n]
        prev[n] = u
      end
    end
  end

  return print(dist, prev, NUM_NODES)
end

File.open('dijkstra.csv', 'w') { |file| file.write(dijkstra(graph, 0)) }


  
