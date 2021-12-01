defmodule Day06.World do
  def boundaries(sinks) do
    Enum.reduce(sinks, nil, fn
      {sink_x, sink_y}, nil ->
        {{sink_x, sink_y}, {sink_x, sink_y}}

      {sink_x, sink_y}, {{min_x, min_y}, {max_x, max_y}} ->
        {{min(min_x, sink_x), min(min_y, sink_y)}, {max(max_x, sink_x), max(max_y, sink_y)}}
    end)
  end

  @doc """
    iex> Day06.World.distance({1, 93}, {23, 623})
    552
  """
  def distance({x1, y1}, {x2, y2}),
    do: abs(x1 - x2) + abs(y1 - y2)
end
