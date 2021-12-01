defmodule ModeMaze do
  alias ModeMaze.Cave

  @spec solve :: {non_neg_integer, non_neg_integer}
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
    {114, 45}
  """
  def solve_input(input) do
    cave =
      input
      |> Cave.parse()

    {first, new_cave} =
      cave
      |> Cave.area_risk_level()

    traversed_cave =
      new_cave
      |> Cave.traverse(150)

    second =
      traversed_cave
      |> Cave.time_to_rescue()

    {first, second}
  end
end
