ids = File.read('input.txt').lines.map(&:chomp)

def detect(id)
  h = id.chars.each_with_object(Hash.new(0)) { |char, hash| hash[char] += 1 }
  [h.find { |k, v| v == 2 } && 1 || 0, h.find { |k, v| v == 3 } && 1 || 0]
end

doubles, triples = ids.reduce([0, 0]) do |(doubles, triples), id|
  double, triple = detect(id)
  [doubles + double, triples + triple]
end

puts "First star:"
puts doubles * triples

def distance(first, second)
  first.chars.zip(second.chars).count { |a, b| a != b }
end

close = ids.combination(2).find { |a, b| distance(a, b) == 1 }

puts "Second star:"
puts close
