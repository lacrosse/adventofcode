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
    case do_constellate(simple_constellations) do
      ^simple_constellations -> simple_constellations
      new_constellations -> constellate(new_constellations)
    end
  end

  defp do_constellate(simple_constellations) do
    simple_constellations
    |> Enum.reduce(%MapSet{}, fn simpler_constellation, current_constellations ->
      case Enum.find(current_constellations, &constellate?(&1, simpler_constellation)) do
        nil ->
          current_constellations
          |> MapSet.put(simpler_constellation)

        matching_constellation ->
          new_constellation = MapSet.union(matching_constellation, simpler_constellation)

          current_constellations
          |> MapSet.delete(matching_constellation)
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
