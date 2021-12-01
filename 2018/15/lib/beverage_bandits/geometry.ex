defmodule BeverageBandits.Geometry do
  @type coords() :: {integer(), integer()}
  @type coords_set() :: MapSet.t(coords())
  @type path :: [coords()]

  @spec reading_order(coords()) :: coords()
  def reading_order({x, y}), do: {y, x}

  @spec neighbors(coords()) :: [coords()]
  def neighbors({x, y}) do
    [{x, y - 1}, {x - 1, y}, {x + 1, y}, {x, y + 1}]
  end

  @spec neighbors(coords(), coords_set()) :: [coords()]
  def neighbors(coords, obstacles) do
    coords
    |> neighbors()
    |> Enum.reject(&MapSet.member?(obstacles, &1))
  end
end
