defmodule ReservoirResearch do
  alias ReservoirResearch.Ground

  @spec solve() :: {non_neg_integer(), non_neg_integer()}
  def solve do
    "input.txt"
    |> File.read!()
    |> solve_input()
  end

  @doc """
    iex> input = \"\"\"
    ...> x=495, y=2..7
    ...> y=7, x=495..501
    ...> x=501, y=3..7
    ...> x=498, y=2..4
    ...> x=506, y=1..2
    ...> x=498, y=10..13
    ...> x=504, y=10..13
    ...> y=13, x=498..504
    ...> \"\"\"
    iex> ReservoirResearch.solve_input(input)
    57

    iex> input = \"\"\"
    ...> x=500, y=2..2
    ...> x=498, y=6..9
    ...> x=502, y=6..9
    ...> y=9, x=498..502
    ...> \"\"\"
    iex> ReservoirResearch.solve_input(input)
    33
  """
  def solve_input(input) do
    input
    |> Ground.parse()
    |> Ground.pour()
    |> Ground.measure_secondary_water()
  end
end
