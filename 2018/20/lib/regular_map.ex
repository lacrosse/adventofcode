defmodule RegularMap do
  alias RegularMap.Map, as: RMap

  @spec solve :: {non_neg_integer, non_neg_integer}
  def solve do
    "input.txt"
    |> File.read!()
    |> String.trim_trailing()
    |> solve_input()
  end

  @doc """
    iex> RegularMap.solve_input("^ENWWW(NEEE|SSE(EE|N))$")
    {10, 0}

    iex> RegularMap.solve_input("^WNE$")
    {3, 0}

    iex> RegularMap.solve_input("^ENNWSWW(NEWS|)SSSEEN(WNSE|)EE(SWEN|)NNN$")
    {18, 0}
  """
  def solve_input(input) do
    [string] = Regex.run(~r/\A\^(.+)\$\z/, input, capture: :all_but_first)

    {_, rmap} = RMap.traverse(%RMap{}, string)

    {RMap.diameter(rmap), RMap.unexplored_rooms(rmap, 999)}
  end
end
