require "set"

test_input = <<~EOF
  1163751742
  1381373672
  2136511328
  3694931569
  7463417111
  1319128137
  1359912421
  3125421639
  1293138521
  2311944581
EOF

input = File.read("input.txt")

def solve_input(input)
  input_grid = input.lines.map { _1.chomp.chars.map(&:to_i) }
  height = input_grid.size
  width = input_grid[0].size

  grid =
    (0..).lazy
      .map { |inc| input_grid.map { |row| row.map { (_1 + inc - 1) % 9 + 1 } } }
      .each_cons(5)
      .map { |cons| cons.transpose.map { _1.flat_map(&:itself) } }
      .take(5)
      .flat_map(&:itself)
      .force

  q = [[0, 0]]
  v = Set[]
  risks = Array.new(height * 5) { Array.new(width * 5, Float::INFINITY) }
  risks[0][0] = 0

  while cur = q.shift
    next unless v.add?(cur)
    x, y = cur
    cur_risk = risks[y][x]

    [[x - 1, y],
     [x + 1, y],
     [x, y - 1],
     [x, y + 1]].each { |x, y|
      next unless (0...width * 5) === x && (0...height * 5) === y
      neigh_risk = cur_risk + grid[y][x]
      if neigh_risk < risks[y][x]
        risks[y][x] = neigh_risk
        i = q.bsearch_index { |q_x, q_y| risks[y][x] < risks[q_y][q_x] } || q.size
        q.insert(i, [x, y])
      end
    }
  end

  [risks[height - 1][width - 1],
   risks[height * 5 - 1][width * 5 - 1]]
end

[test_input, input].each { puts solve_input(_1).inspect }
