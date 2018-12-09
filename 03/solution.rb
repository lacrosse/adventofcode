require 'set'

def count_doubles(cloth)
  cloth.reduce(0) { |s, col| s + col.count { |p| p > 1 } }
end

def visualize(cloth)
  cloth.each { |row| puts row.join }
end

def apply_claims(claims)
  rects = claims.map do |claim|
    {
      a: claim.slice(:x, :y),
      b: {
        x: claim[:x] + claim[:width],
        y: claim[:y] + claim[:height]
      }
    }
  end

  furthermost = rects.reduce(x: 0, y: 0) do |s, rect|
    {
      x: [s[:x], rect[:b][:x]].max,
      y: [s[:y], rect[:b][:y]].max
    }
  end

  empty_cloth = Array.new(furthermost[:x] + 1) { Array.new(furthermost[:y] + 1, 0) }

  rects.each_with_object(empty_cloth) do |rect, cloth|
    (rect[:a][:x]...rect[:b][:x]).each do |x|
      (rect[:a][:y]...rect[:b][:y]).each do |y|
        cloth[x][y] += 1
      end
    end
  end
end

def count_overlap_inches(claims)
  claims
    .yield_self(&method(:apply_claims))
    .yield_self(&method(:count_doubles))
end

def find_standalone(claims)
  rects = claims.map do |claim|
    {
      id: claim[:id],
      a: claim.slice(:x, :y),
      b: {
        x: claim[:x] + claim[:width],
        y: claim[:y] + claim[:height]
      }
    }
  end

  furthermost = rects.reduce(x: 0, y: 0) do |s, rect|
    {
      x: [s[:x], rect[:b][:x]].max,
      y: [s[:y], rect[:b][:y]].max
    }
  end

  empty_cloth = Array.new(furthermost[:x] + 1) { Array.new(furthermost[:y] + 1) { [] } }

  tainted = Set.new

  rects.each_with_object(empty_cloth) do |rect, cloth|
    (rect[:a][:x]...rect[:b][:x]).each do |x|
      (rect[:a][:y]...rect[:b][:y]).each do |y|
        cloth[x][y] << rect[:id]
        tainted += cloth[x][y] if cloth[x][y].count > 1
      end
    end
  end

  (claims.map { |c| c[:id] }.to_set - tainted).to_a[0]
end

claims = File.read('input.txt').lines.map do |line|
  id, x, y, width, height = line.chomp.match(/\A#(\d+) @ (\d+),(\d+): (\d+)x(\d+)/).captures.map(&:to_i)

  {
    id: id,
    x: x,
    y: y,
    width: width,
    height: height
  }
end

puts 'First star:'
puts count_overlap_inches(claims)

puts 'Second star:'
puts find_standalone(claims)
