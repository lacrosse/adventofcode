defmodule SettlersOfTheNorthPole do
  alias SettlersOfTheNorthPole.Farm

  @spec solve :: {non_neg_integer, non_neg_integer}
  def solve do
    "input.txt"
    |> File.read!()
    |> solve_input()
  end

  @doc """
    iex> input = \"\"\"
    ...> .#.#...|#.
    ...> .....#|##|
    ...> .|..|...#.
    ...> ..|#.....#
    ...> #.#|||#|#|
    ...> ...#.||...
    ...> .|....|...
    ...> ||...#|.#|
    ...> |.||||..|.
    ...> ...#.|..|.
    ...> \"\"\"
    iex> SettlersOfTheNorthPole.solve_input(input)
    {1147, 0}
  """
  def solve_input(input) do
    ten =
      input
      |> Farm.parse()
      |> Farm.evolve(10)

    billion =
      ten
      |> Farm.evolve(1_000_000_000 - 10)

    {Farm.score(ten), Farm.score(billion)}
  end
end
