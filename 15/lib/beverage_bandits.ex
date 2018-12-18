defmodule BeverageBandits do
  alias BeverageBandits.Cave

  @spec solve() :: non_neg_integer()
  def solve do
    'input.txt'
    |> File.read!()
    |> solve_input()
  end

  @doc """
    iex> input = \"\"\"
    ...> #######
    ...> #.G...#
    ...> #...EG#
    ...> #.#.#G#
    ...> #..G#E#
    ...> #.....#
    ...> #######
    ...> \"\"\"
    iex> BeverageBandits.solve_input(input)
    27730

    iex> input = \"\"\"
    ...> #######
    ...> #E..EG#
    ...> #.#G.E#
    ...> #E.##E#
    ...> #G..#.#
    ...> #..E#.#
    ...> #######
    ...> \"\"\"
    iex> BeverageBandits.solve_input(input)
    39514

    iex> input = \"\"\"
    ...> #######
    ...> #E.G#.#
    ...> #.#G..#
    ...> #G.#.G#
    ...> #G..#.#
    ...> #...E.#
    ...> #######
    ...> \"\"\"
    iex> BeverageBandits.solve_input(input)
    27755

    iex> input = \"\"\"
    ...> #######
    ...> #.E...#
    ...> #.#..G#
    ...> #.###.#
    ...> #E#G#G#
    ...> #...#G#
    ...> #######
    ...> \"\"\"
    iex> BeverageBandits.solve_input(input)
    28944

    iex> input = \"\"\"
    ...> #######
    ...> #G..#E#
    ...> #E#E.E#
    ...> #G.##.#
    ...> #...#E#
    ...> #...E.#
    ...> #######
    ...> \"\"\"
    iex> BeverageBandits.solve_input(input)
    36334

    iex> input = \"\"\"
    ...> #########
    ...> #G......#
    ...> #.E.#...#
    ...> #..##..G#
    ...> #...##..#
    ...> #...#...#
    ...> #.G...G.#
    ...> #.....G.#
    ...> #########
    ...> \"\"\"
    iex> BeverageBandits.solve_input(input)
    18740

    iex> input = \"\"\"
    ...> ####
    ...> ##E#
    ...> #GG#
    ...> ####
    ...> \"\"\"
    iex> BeverageBandits.solve_input(input)
    13400

    iex> input = \"\"\"
    ...> #####
    ...> #GG##
    ...> #.###
    ...> #..E#
    ...> #.#G#
    ...> #.E##
    ...> #####
    ...> \"\"\"
    iex> BeverageBandits.solve_input(input)
    13987

    iex> input = \"\"\"
    ...> #######
    ...> #.E..G#
    ...> #.#####
    ...> #G#####
    ...> #######
    ...> \"\"\"
    iex> BeverageBandits.solve_input(input)
    10234

    iex> input = \"\"\"
    ...> ################
    ...> #.......G......#
    ...> #G.............#
    ...> #..............#
    ...> #....###########
    ...> #....###########
    ...> #.......EG.....#
    ...> ################
    ...> \"\"\"
    iex> BeverageBandits.solve_input(input)
    18468
  """
  @spec solve_input(String.t()) :: pos_integer()
  def solve_input(input) do
    input
    |> Cave.init()
    |> Cave.battle_result()
  end
end
