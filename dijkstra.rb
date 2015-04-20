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

File.open('dijkstra.csv', 'w') { |file| file.write(dijkstra(graph, 0)) }


  
