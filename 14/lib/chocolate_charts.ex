defmodule ChocolateCharts do
  alias ChocolateCharts.Chart

  def solve do
    'input.txt'
    |> File.read!()
    |> String.trim_trailing()
    |> String.to_integer()
    |> solve_input()
  end

  @doc """
    iex> ChocolateCharts.solve_input(5)
    "0124515891"

    iex> ChocolateCharts.solve_input(18)
    "9251071085"

    iex> ChocolateCharts.solve_input(2018)
    "5941429882"

    iex> ChocolateCharts.solve_input(9)
    "5158916779"
  """
  def solve_input(input) do
    %Chart{}
    |> Chart.score_after(input)
  end
end
