defmodule Day06.MultipleEscape do
  alias Day06.World

  @doc """
      iex> sinks = [
      ...>   {1, 1},
      ...>   {1, 6},
      ...>   {8, 3},
      ...>   {3, 4},
      ...>   {5, 5},
      ...>   {8, 9}
      ...> ]
      iex> Day06.MultipleEscape.find_closest_area(sinks, 32)
      16
  """
  def find_closest_area(sinks, threshold) do
    sinks
    |> create_world_from_sinks()
    |> find_area(threshold)
  end

  def create_world_from_sinks(sinks) do
    {{min_x, min_y}, {max_x, max_y}} = {home, work} = World.boundaries(sinks)

    grid =
      for(x <- min_x..max_x, y <- min_y..max_y, do: {x, y})
      |> Enum.map(fn point ->
        sink_distances =
          sinks
          |> Enum.map(&{&1, World.distance(&1, point)})

        {point, sink_distances}
      end)
      |> create_grid_from_point_sink_distances()

    {grid, home, work}
  end

  def create_grid_from_point_sink_distances(point_sink_distances) do
    point_sink_distances
    |> Enum.map(fn {point, sink_distances} ->
      total_distance = Enum.reduce(sink_distances, 0, fn {_, distance}, acc -> acc + distance end)

      {point, total_distance}
    end)
    |> Enum.into(%{})
  end

  def find_area({grid, _, _}, threshold) do
    Enum.count(grid, &(elem(&1, 1) < threshold))
  end
end
