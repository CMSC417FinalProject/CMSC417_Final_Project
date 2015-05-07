 path1 = "[\"n1\", \"n2\"]"
 path = path1.delete("[").delete("]").delete("\"").delete(" ")

 puts path.inspect

 arr = ["n11", "n12"]

 puts arr.to_s
 puts arr.inspect
 puts arr
