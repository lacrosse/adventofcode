defmodule ExperimentalEmergencyTeleportation.Swarm do
  defstruct bots: %{}

  @type coords :: {integer, integer, integer}
  @type radius :: pos_integer
  @type t :: %__MODULE__{bots: %{optional(coords) => radius}}

  @spec parse(binary) :: t
  def parse(input) do
    bots =
      input
      |> String.split(~r/\n/, trim: true)
      |> Enum.map(fn bot_def ->
        [x, y, z, r] =
          Regex.run(~r/\Apos=<(-?\d+),(-?\d+),(-?\d+)>, r=(\d+)/, bot_def, capture: :all_but_first)
          |> Enum.map(&String.to_integer/1)

        {{x, y, z}, r}
      end)
      |> Enum.into(%{})

    %__MODULE__{bots: bots}
  end

  @spec in_range_of_strongest(t) :: non_neg_integer
  def in_range_of_strongest(%__MODULE__{bots: bots} = swarm) do
    {center_coords, center_radius} = strongest(swarm)
    Enum.count(bots, fn {coords, _} -> within?(center_coords, center_radius, coords) end)
  end

  @spec strongest_signal_distance(t) :: non_neg_integer
  def strongest_signal_distance(%__MODULE__{bots: bots} = swarm) do
    {{{min_x, _, _}, _}, {{max_x, _, _}, _}} = Enum.min_max_by(bots, fn {{x, _, _}, _} -> x end)
    {{{_, min_y, _}, _}, {{_, max_y, _}, _}} = Enum.min_max_by(bots, fn {{_, y, _}, _} -> y end)
    {{{_, _, min_z}, _}, {{_, _, max_z}, _}} = Enum.min_max_by(bots, fn {{_, _, z}, _} -> z end)

    binary_max_x = extend_to_nearest_binary_power(min_x, max_x)
    binary_max_y = extend_to_nearest_binary_power(min_y, max_y)
    binary_max_z = extend_to_nearest_binary_power(min_z, max_z)

    heap =
      Heap.new(&signal_cuboid_priority/2)
      |> Heap.push({1000, {min_x..binary_max_x, min_y..binary_max_y, min_z..binary_max_z}})

    coords = traverse_cuboids(swarm, heap)

    manhattan_distance(coords, {0, 0, 0})
  end

  defp extend_to_nearest_binary_power(a, b) do
    power = (b - a + 1) |> :math.log2() |> :math.ceil()
    a + trunc(:math.pow(2, power)) - 1
  end

  defp traverse_cuboids(swarm, signal_cuboid_heap) do
    {{_, cuboid}, new_signal_cuboid_heap} = Heap.split(signal_cuboid_heap)

    case cuboid do
      {x..x, y..y, z..z} ->
        {x, y, z}

      _ ->
        subcuboid_signals =
          cuboid
          |> split_into_subcuboids()
          |> Enum.map(fn subcuboid -> {measure_signal(swarm, subcuboid), subcuboid} end)

        new_signal_cuboid_heap =
          subcuboid_signals
          |> Enum.reduce(new_signal_cuboid_heap, fn subcuboid_signal, heap ->
            Heap.push(heap, subcuboid_signal)
          end)

        traverse_cuboids(swarm, new_signal_cuboid_heap)
    end
  end

  defp signal_cuboid_priority({signal_1, _}, {signal_2, _}) when signal_1 > signal_2, do: true

  defp signal_cuboid_priority({signal, cuboid_1}, {signal, cuboid_2}) do
    spatial_manhattan_distance(cuboid_1, {0, 0, 0}) <
      spatial_manhattan_distance(cuboid_2, {0, 0, 0})
  end

  defp signal_cuboid_priority(_, _) do
    false
  end

  defp split_into_subcuboids({min_x..max_x, min_y..max_y, min_z..max_z}) do
    x_half_width = div(max_x - min_x + 1, 2)
    y_half_width = div(max_y - min_y + 1, 2)
    z_half_width = div(max_z - min_z + 1, 2)

    for x_range <- [min_x..(min_x + x_half_width - 1), (min_x + x_half_width)..max_x],
        y_range <- [min_y..(min_y + y_half_width - 1), (min_y + y_half_width)..max_y],
        z_range <- [min_z..(min_z + z_half_width - 1), (min_z + z_half_width)..max_z],
        subcuboid = {x_range, y_range, z_range},
        max_x >= min_x and max_y >= min_y and max_z >= min_z,
        do: subcuboid
  end

  defp strongest(%__MODULE__{bots: bots}),
    do: Enum.max_by(bots, fn {_, r} -> r end)

  defp measure_signal(%__MODULE__{bots: bots}, cuboid) do
    Enum.count(bots, fn {bot_coords, bot_radius} ->
      spatial_manhattan_distance(cuboid, bot_coords) <= bot_radius
    end)
  end

  defp within?(center, radius, point),
    do: manhattan_distance(center, point) <= radius

  defp manhattan_distance({x_1, y_1, z_1}, {x_2, y_2, z_2}),
    do: abs(x_2 - x_1) + abs(y_2 - y_1) + abs(z_2 - z_1)

  defp spatial_manhattan_distance({min_x..max_x, min_y..max_y, min_z..max_z}, {x, y, z} = coords) do
    manhattan_distance(
      coords,
      {
        x |> min(max_x) |> max(min_x),
        y |> min(max_y) |> max(min_y),
        z |> min(max_z) |> max(min_z)
      }
    )
  end
end
