defmodule ExperimentalEmergencyTeleportation.Swarm do
  defstruct bots: %{}

  @type coords :: {non_neg_integer, non_neg_integer, non_neg_integer}
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
    {strongest_coords, strongest_radius} = strongest(swarm)

    bots
    |> Enum.filter(fn {coords, _} -> within?(strongest_coords, strongest_radius, coords) end)
    |> Enum.count()
  end

  defp strongest(%__MODULE__{bots: bots}),
    do: Enum.max_by(bots, fn {_, r} -> r end)

  defp within?(center, radius, point),
    do: manhattan_distance(center, point) <= radius

  defp manhattan_distance({x_1, y_1, z_1}, {x_2, y_2, z_2}),
    do: abs(x_2 - x_1) + abs(y_2 - y_1) + abs(z_2 - z_1)
end
