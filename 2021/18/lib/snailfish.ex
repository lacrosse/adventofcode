defmodule Snailfish do
  alias __MODULE__.{Number, Composite}

  @doc """
  ## Examples
    iex> input = \"\"\"
    ...> [[[0,[5,8]],[[1,7],[9,6]]],[[4,[1,2]],[[1,4],2]]]
    ...> [[[5,[2,8]],4],[5,[[9,9],0]]]
    ...> [6,[[[6,2],[5,6]],[[7,6],[4,7]]]]
    ...> [[[6,[0,7]],[0,9]],[4,[9,[9,0]]]]
    ...> [[[7,[6,4]],[3,[1,3]]],[[[5,5],1],9]]
    ...> [[6,[[7,3],[3,2]]],[[[3,8],[5,7]],4]]
    ...> [[[[5,4],[7,7]],8],[[8,3],8]]
    ...> [[9,3],[[9,9],[6,[4,9]]]]
    ...> [[2,[[7,7],7]],[[5,8],[[9,3],[0,2]]]]
    ...> [[[[5,2],5],[8,[3,7]]],[[5,[7,5]],[4,4]]]
    ...> \"\"\"
    iex> Snailfish.solve_input(input)
    {4140, 3993}
  """
  def solve_input(input) do
    snailfish_numbers =
      input
      |> String.split(~r/\n/, trim: true)
      |> Enum.map(&Composite.from_string/1)

    first =
      snailfish_numbers
      |> Enum.reduce(&Composite.add(&2, &1))
      |> Number.magnitude()

    second =
      snailfish_numbers
      |> permutations()
      |> Enum.map(fn {n1, n2} -> Composite.add(n1, n2) |> Number.magnitude() end)
      |> Enum.max()

    {first, second}
  end

  def solve do
    File.read!("input.txt")
    |> solve_input()
  end

  defp permutations([h | t]), do: Enum.flat_map(t, &[{h, &1}, {&1, h}]) ++ permutations(t)
  defp permutations([]), do: []
end
