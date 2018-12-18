defmodule BeverageBandits do
  alias BeverageBandits.Cave

  @spec solve() :: {non_neg_integer(), non_neg_integer()}
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
    {27730, 4988}

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
    {39514, 31284}

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
    {27755, 3478}

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
    {28944, 6474}

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
    {36334, 29064}

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
    {18740, 1140}
  """
  @spec solve_input(binary()) :: {pos_integer(), pos_integer()}
  def solve_input(input) do
    first =
      input
      |> Cave.init()
      |> Cave.battle_result()

    second =
      input
      |> Cave.init()
      |> Cave.winning_battle_result()

    {first, second}
  end
end
