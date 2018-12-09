polymer = File.read('input.txt').chomp

NIHILS = (('a'..'z').zip('A'..'Z') + ('A'..'Z').zip('a'..'z')).map { |a, b| a + b }

def reduce(polymer)
  NIHILS.reduce(polymer) { |str, pair| str.gsub(pair, '') }
end

def full_reduce(polymer)
  loop { break unless polymer.length > (polymer = reduce(polymer)).length }
  polymer
end

reduced_polymer = full_reduce(polymer)

puts 'First star:'
puts reduced_polymer.length

shortest_polymer_length = ('a'..'z').map do |monomer|
  full_reduce(reduced_polymer.gsub(/#{monomer}/i, '')).length
end.min

puts 'Second star:'
puts shortest_polymer_length
