defmodule ModeMaze do
  alias ModeMaze.Cave

  def solve do
    "input.txt"
    |> File.read!()
    |> solve_input()
  end

  @doc """
    iex> input = \"\"\"
    ...> depth: 510
    ...> target: 10,10
    ...> \"\"\"
    iex> ModeMaze.solve_input(input)
    114
  """
  def solve_input(input) do
    input
    |> Cave.parse()
    |> Cave.area_risk_level()
  end
end
