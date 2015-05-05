nta = File.readlines(ARGV[0])
list_of_nodes = []
nta.each{ |line| 
    n = line.split[0...1].join(' ')
    list_of_nodes.push(n)
}
list_of_nodes = (list_of_nodes.uniq).sort
puts list_of_nodes
num_of_nodes = list_of_nodes.count
puts num_of_nodes