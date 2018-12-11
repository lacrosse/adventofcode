defmodule Day08 do
  alias Day08.Tree

  def solve do
    input = 'input.txt' |> File.read!() |> String.trim_trailing()

    solve_input(input)
  end

  @doc """
    iex> input = "2 3 0 3 10 11 12 1 1 0 1 99 2 1 1 2"
    iex> Day08.solve_input(input)
    {138, 66}
  """
  def solve_input(input) do
    tree =
      input
      |> String.split()
      |> Enum.map(&String.to_integer/1)
      |> Tree.from_definition()

    {solve_first(tree), solve_second(tree)}
  end

  def solve_first(tree), do: Tree.sum_metadata(tree)
  def solve_second(tree), do: Tree.value(tree)
end
