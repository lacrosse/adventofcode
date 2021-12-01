defmodule Day06.SingleEscape do
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
      iex> Day06.SingleEscape.find_max_finite_area(MapSet.new(sinks))
      17
  """
  def find_max_finite_area(sinks) do
    world = create_world_from_sinks(sinks)

    infinite_sinks = detect_infinite_sinks(world)

    {_, max_finite_area} =
      world
      |> detect_sink_areas()
      |> Enum.reject(fn {sink, _} ->
        MapSet.member?(infinite_sinks, sink)
      end)
      |> Enum.max_by(fn {_, area} -> area end)

    max_finite_area
  end

  @doc """
    iex> Day06.SingleEscape.create_world_from_sinks([{1, 3}, {3, 1}])
    {%{
      {1, 1} => nil,
      {1, 2} => {1, 3},
      {1, 3} => {1, 3},
      {2, 1} => {3, 1},
      {2, 2} => nil,
      {2, 3} => {1, 3},
      {3, 1} => {3, 1},
      {3, 2} => {3, 1},
      {3, 3} => nil
    }, {1, 1}, {3, 3}}
  """
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

  def detect_infinite_sinks({grid, {home_x, home_y}, {work_x, work_y}}) do
    x_track =
      for x <- home_x..work_x,
          y <- [home_y, work_y],
          do: {x, y}

    y_track =
      for y <- home_y..work_y,
          x <- [home_x, work_x],
          do: {x, y}

    (x_track ++ y_track)
    |> Enum.map(&Map.get(grid, &1))
    |> Enum.filter(& &1)
    |> Enum.into(MapSet.new())
  end

  def detect_sink_areas({grid, _, _}) do
    grid
    |> Enum.group_by(&elem(&1, 1))
    |> Enum.map(fn {sink, ls} -> {sink, Enum.count(ls)} end)
    |> Enum.into(%{})
  end

  def create_grid_from_point_sink_distances(point_sink_distances) do
    for {point, sink_distances} <- point_sink_distances do
      closest_sinks =
        sink_distances
        |> Enum.group_by(&elem(&1, 1), &elem(&1, 0))
        |> Enum.min_by(&elem(&1, 0))
        |> elem(1)

      sink =
        case closest_sinks do
          [one] -> one
          _ -> nil
        end

      {point, sink}
    end
    |> Enum.into(%{})
  end
end
