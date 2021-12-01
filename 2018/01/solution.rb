ops = File.read('input.txt').lines.map(&:to_i)

res_1 = ops.reduce(0) do |s, op|
  s + op
end

puts "First star:"
puts res_1

require 'set'

freqs = Set.new

res_2 = ops.cycle.reduce(0) do |s, op|
  new_s = s + op
  break new_s unless freqs.add?(new_s)
  new_s
end

puts "Second star:"
puts res_2
