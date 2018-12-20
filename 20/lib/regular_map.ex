defmodule RegularMap do
  alias RegularMap.Map, as: RMap

  @spec solve :: non_neg_integer
  def solve do
    "input.txt"
    |> File.read!()
    |> String.trim_trailing()
    |> solve_input()
  end

  @doc """
    iex> RegularMap.solve_input("^ENWWW(NEEE|SSE(EE|N))$")
    10

    iex> RegularMap.solve_input("^WNE$")
    3

    iex> RegularMap.solve_input("^ENNWSWW(NEWS|)SSSEEN(WNSE|)EE(SWEN|)NNN$")
    18
  """
  def solve_input(input) do
    [string] = Regex.run(~r/\A\^(.+)\$\z/, input, capture: :all_but_first)

    {_, rmap} = RMap.traverse(%RMap{}, string)

    RMap.diameter(rmap)
  end
end
