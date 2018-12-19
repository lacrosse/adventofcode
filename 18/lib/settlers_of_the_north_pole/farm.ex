defmodule SettlersOfTheNorthPole.Farm do
  defstruct acres: %{}, width: 0, length: 0

  @type coord :: non_neg_integer
  @type coords :: {coord, coord}
  @type acre :: :open | :tree | :lumberyard
  @type t :: %__MODULE__{acres: %{optional(coords) => acre}}

  @spec parse(binary) :: t
  def parse(input) do
    lines =
      input
      |> String.split(~r/\n/, trim: true)

    width = lines |> Enum.at(0) |> String.length()
    length = lines |> Enum.count()

    acres =
      lines
      |> Enum.with_index()
      |> Enum.flat_map(fn {line, y} ->
        line
        |> String.codepoints()
        |> Enum.with_index()
        |> Enum.map(fn {c, x} -> {{x, y}, char_to_acre(c)} end)
      end)
      |> Enum.into(%{})

    %__MODULE__{acres: acres, width: width, length: length}
  end

  @spec evolve(t, integer, %{optional(t) => non_neg_integer}) :: t
  def evolve(farm, minutes, generations \\ %{})

  def evolve(%__MODULE__{} = farm, 0, _), do: farm

  def evolve(%__MODULE__{} = farm, minutes, generations) do
    new_tick = tick(farm)
    new_minutes = minutes - 1

    case Map.get(generations, new_tick) do
      nil ->
        evolve(new_tick, new_minutes, Map.put(generations, new_tick, new_minutes))

      previous_minute ->
        evolve(new_tick, rem(new_minutes, previous_minute - new_minutes), %{})
    end
  end

  @spec score(t) :: non_neg_integer
  def score(%__MODULE__{acres: acres}) do
    trees = Enum.count(acres, &(elem(&1, 1) == :tree))
    lumberyards = Enum.count(acres, &(elem(&1, 1) == :lumberyard))

    trees * lumberyards
  end

  defp tick(%__MODULE__{acres: acres, width: width, length: length} = farm) do
    new_acres =
      for y <- 0..(length - 1),
          x <- 0..(width - 1),
          acre_coords = {x, y},
          acre = Map.fetch!(acres, acre_coords),
          neighbors = acre_coords |> neighbors() |> Enum.map(&Map.get(acres, &1)),
          into: %{} do
        new_acre =
          case acre do
            :open ->
              if Enum.count(neighbors, &(&1 == :tree)) >= 3,
                do: :tree,
                else: :open

            :tree ->
              if Enum.count(neighbors, &(&1 == :lumberyard)) >= 3,
                do: :lumberyard,
                else: :tree

            :lumberyard ->
              if Enum.count(neighbors, &(&1 == :lumberyard)) >= 1 and
                   Enum.count(neighbors, &(&1 == :tree)) >= 1,
                 do: :lumberyard,
                 else: :open
          end

        {acre_coords, new_acre}
      end

    %__MODULE__{farm | acres: new_acres}
  end

  defp neighbors({x, y}),
    do: [
      {x, y - 1},
      {x + 1, y - 1},
      {x + 1, y},
      {x + 1, y + 1},
      {x, y + 1},
      {x - 1, y + 1},
      {x - 1, y},
      {x - 1, y - 1}
    ]

  defp char_to_acre("."), do: :open
  defp char_to_acre("|"), do: :tree
  defp char_to_acre("#"), do: :lumberyard
  defp acre_to_char(:open), do: "."
  defp acre_to_char(:tree), do: "|"
  defp acre_to_char(:lumberyard), do: "#"

  @spec visualize(t) :: t
  def visualize(%__MODULE__{acres: acres, width: width, length: length} = farm) do
    IO.puts("Farm:")

    for y <- 0..(length - 1) do
      for x <- 0..(width - 1) do
        acre_to_char(Map.get(acres, {x, y}))
      end
      |> Enum.join()
      |> IO.puts()
    end

    farm
  end
end
