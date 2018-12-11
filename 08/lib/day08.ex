defmodule Day08 do
  alias Day08.Tree

  def solve do
    input = 'input.txt' |> File.read!() |> String.trim_trailing()

    {solve_first(input), solve_second(input)}
  end

  @doc """
    iex> input = "2 3 0 3 10 11 12 1 1 0 1 99 2 1 1 2"
    iex> Day08.solve_first(input)
    138
  """
  def solve_first(input) do
    input
    |> String.split()
    |> Enum.map(&String.to_integer/1)
    |> Tree.from_definition()
    |> Tree.sum_metadata()
  end

  def solve_second(_) do
  end
end
