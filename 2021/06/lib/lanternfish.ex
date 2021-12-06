defmodule Lanternfish do
  def solve do
    "input.txt"
    |> File.read!()
    |> solve_input()
  end

  @doc """
  ## Example
    iex> Lanternfish.solve_input("3,4,3,1,2")
    {5934, 26984457539}
  """
  def solve_input(input) do
    map =
      input
      |> String.trim()
      |> String.split(",")
      |> Enum.map(&String.to_integer/1)
      |> Enum.group_by(&Function.identity/1)

    fish =
      0..8
      |> Enum.map(&(map |> Map.get(&1, []) |> Enum.count()))
      |> List.to_tuple()

    [first, second] =
      [80, 256 - 80]
      |> Enum.scan(fish, &breed(&2, &1))
      |> Enum.map(&count/1)

    {first, second}
  end

  defp breed(fish, 0), do: fish

  defp breed({zero, one, two, three, four, five, six, seven, eight}, days),
    do: breed({one, two, three, four, five, six, seven + zero, eight, zero}, days - 1)

  defp count(fish), do: fish |> Tuple.to_list() |> Enum.sum()
end
