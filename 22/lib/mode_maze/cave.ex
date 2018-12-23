defmodule ModeMaze.Cave do
  defstruct target: nil, depth: nil, risk_levels: %{}, geologic_indices: %{}, erosion_levels: %{}

  @type coords :: {non_neg_integer, non_neg_integer}
  @type geologic_index :: non_neg_integer
  @type erosion_level :: non_neg_integer
  @type risk_level :: 0 | 1 | 2
  @type t :: %__MODULE__{
          target: coords,
          depth: pos_integer,
          risk_levels: %{optional(coords) => risk_level},
          geologic_indices: %{optional(coords) => geologic_index},
          erosion_levels: %{optional(coords) => erosion_level}
        }

  @spec parse(binary) :: t
  def parse(input) do
    [depth, x, y] =
      Regex.run(~r/depth: (\d+)\ntarget: (\d+),(\d+)\n\z/, input, capture: :all_but_first)
      |> Enum.map(&String.to_integer/1)

    %__MODULE__{depth: depth, target: {x, y}}
  end

  def area_risk_level(%__MODULE__{target: {t_x, t_y}} = cave) do
    {region_risk_levels, _new_cave} =
      for(x <- 0..t_x, y <- 0..t_y, do: {x, y})
      |> Enum.map_reduce(cave, fn region, current_cave ->
        risk_level(current_cave, region)
      end)

    Enum.sum(region_risk_levels)
  end

  @spec geologic_index(t, coords) :: {geologic_index, t}
  def geologic_index(%__MODULE__{} = cave, {0, 0}), do: {0, cave}
  def geologic_index(%__MODULE__{target: target} = cave, target), do: {0, cave}
  def geologic_index(%__MODULE__{} = cave, {x, 0}), do: {x * 16807, cave}
  def geologic_index(%__MODULE__{} = cave, {0, y}), do: {y * 48271, cave}

  def geologic_index(%__MODULE__{geologic_indices: geologic_indices} = cave, {x, y}) do
    case Map.get(geologic_indices, {x, y}) do
      nil ->
        {left_erosion_index, new_cave} = erosion_level(cave, {x - 1, y})
        {top_erosion_index, new_cave} = erosion_level(new_cave, {x, y - 1})
        computed_geologic_index = left_erosion_index * top_erosion_index
        new_geologic_indices = Map.put(geologic_indices, {x, y}, computed_geologic_index)
        new_cave = %__MODULE__{new_cave | geologic_indices: new_geologic_indices}
        {computed_geologic_index, new_cave}

      geologic_index ->
        {geologic_index, cave}
    end
  end

  @spec erosion_level(t, coords) :: {erosion_level, t}
  def erosion_level(%__MODULE__{depth: depth, erosion_levels: erosion_levels} = cave, {x, y}) do
    case Map.get(erosion_levels, {x, y}) do
      nil ->
        {geologic_index, new_cave} = geologic_index(cave, {x, y})
        computed_erosion_level = rem(geologic_index + depth, 20183)
        new_erosion_levels = Map.put(erosion_levels, {x, y}, computed_erosion_level)
        new_cave = %__MODULE__{new_cave | erosion_levels: new_erosion_levels}
        {computed_erosion_level, new_cave}

      erosion_level ->
        {erosion_level, cave}
    end
  end

  @spec risk_level(t, coords) :: {risk_level, t}
  def risk_level(%__MODULE__{risk_levels: risk_levels} = cave, coords) do
    case Map.get(risk_levels, coords) do
      nil ->
        {erosion_level, new_cave} = erosion_level(cave, coords)
        computed_risk_level = rem(erosion_level, 3)
        new_risk_levels = Map.put(risk_levels, coords, computed_risk_level)
        new_cave = %__MODULE__{new_cave | risk_levels: new_risk_levels}
        {computed_risk_level, new_cave}

      risk_level ->
        {risk_level, cave}
    end
  end

  @spec region_type(t, coords) :: :narrow | :rocky | :wet
  def region_type(%__MODULE__{} = cave, coords) do
    case risk_level(cave, coords) do
      {0, _} -> :rocky
      {1, _} -> :wet
      {2, _} -> :narrow
    end
  end
end
