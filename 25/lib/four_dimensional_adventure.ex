defmodule FourDimensionalAdventure do
  @spec solve :: non_neg_integer
  def solve do
    "input.txt"
    |> File.read!()
    |> solve_input()
  end

  @doc """
    iex> input = \"\"\"
    ...> -1,2,2,0
    ...> 0,0,2,-2
    ...> 0,0,0,-2
    ...> -1,2,0,0
    ...> -2,-2,-2,2
    ...> 3,0,2,-1
    ...> -1,3,2,2
    ...> -1,0,-1,0
    ...> 0,2,1,-2
    ...> 3,0,0,0
    ...> \"\"\"
    iex> FourDimensionalAdventure.solve_input(input)
    4
  """
  def solve_input(input) do
    input
    |> String.split(~r/\n/, trim: true)
    |> Enum.map(fn line ->
      [x, y, z, t] =
        Regex.run(~r/\A(-?\d+),(-?\d+),(-?\d+),(-?\d+)\z/, line, capture: :all_but_first)
        |> Enum.map(&String.to_integer/1)

      {x, y, z, t}
    end)
    |> Enum.map(&MapSet.new([&1]))
    |> constellate()
    |> Enum.count()
  end

  defp constellate(simple_constellations) do
    simple_constellations
    |> Enum.reduce(%MapSet{}, fn simple_constellation, current_constellations ->
      case Enum.filter(current_constellations, &constellate?(&1, simple_constellation)) do
        [] ->
          MapSet.put(current_constellations, simple_constellation)

        matching_constellations ->
          new_constellation =
            Enum.reduce(matching_constellations, simple_constellation, &MapSet.union(&2, &1))

          Enum.reduce(matching_constellations, current_constellations, &MapSet.delete(&2, &1))
          |> MapSet.put(new_constellation)
      end
    end)
  end

  defp manhattan_distance({x, y, z, t}, {x_2, y_2, z_2, t_2}),
    do: abs(x_2 - x) + abs(y_2 - y) + abs(z_2 - z) + abs(t_2 - t)

  defp constellate?(const, const_2),
    do: Enum.any?(const_2, &point_constellates?(const, &1))

  defp point_constellates?(constellation, point),
    do: Enum.any?(constellation, &(manhattan_distance(&1, point) <= 3))
end
