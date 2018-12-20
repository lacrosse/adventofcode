defmodule RegularMap.Map do
  defstruct doors: %{}

  @type coords :: {integer, integer}
  @type t :: %__MODULE__{doors: %{optional(coords) => MapSet.t(coords)}}

  @spec traverse(t, binary, coords) :: {coords, t}
  def traverse(rmap, route, coords \\ {0, 0})

  def traverse(rmap, "", coords) do
    {coords, rmap}
  end

  def traverse(rmap, "N" <> route_tail, {x, y} = coords) do
    new_coords = {x, y - 1}
    traverse(open_door(rmap, coords, new_coords), route_tail, new_coords)
  end

  def traverse(rmap, "E" <> route_tail, {x, y} = coords) do
    new_coords = {x + 1, y}
    traverse(open_door(rmap, coords, new_coords), route_tail, new_coords)
  end

  def traverse(rmap, "W" <> route_tail, {x, y} = coords) do
    new_coords = {x - 1, y}
    traverse(open_door(rmap, coords, new_coords), route_tail, new_coords)
  end

  def traverse(rmap, "S" <> route_tail, {x, y} = coords) do
    new_coords = {x, y + 1}
    traverse(open_door(rmap, coords, new_coords), route_tail, new_coords)
  end

  def traverse(rmap, "(" <> route_tail, coords) do
    {branches, new_route_tail} = branches(route_tail)

    {new_coords, new_rmap} =
      branches
      |> Enum.reduce({coords, rmap}, fn branch, {_, current_rmap} ->
        traverse(current_rmap, branch, coords)
      end)

    traverse(new_rmap, new_route_tail, new_coords)
  end

  @spec diameter(t, MapSet.t(coords), MapSet.t(coords), non_neg_integer) :: non_neg_integer
  def diameter(
        %__MODULE__{doors: doors} = rmap,
        frontier \\ MapSet.new([{0, 0}]),
        visited \\ MapSet.new([{0, 0}]),
        acc \\ 0
      ) do
    steps =
      frontier
      |> Enum.reduce(%MapSet{}, fn frontier_coords, current_steps ->
        doors
        |> Map.fetch!(frontier_coords)
        |> MapSet.union(current_steps)
      end)

    new_frontier = MapSet.difference(steps, visited)

    new_visited = MapSet.union(visited, steps)

    if MapSet.size(new_frontier) > 0 do
      diameter(rmap, new_frontier, new_visited, acc + 1)
    else
      acc
    end
  end

  defp open_door(%__MODULE__{doors: doors} = rmap, coords, new_coords) do
    new_doors =
      doors
      |> Map.update(coords, MapSet.new([new_coords]), &MapSet.put(&1, new_coords))
      |> Map.update(new_coords, MapSet.new([coords]), &MapSet.put(&1, coords))

    %__MODULE__{rmap | doors: new_doors}
  end

  defp branches(str, acc \\ "", branches \\ [], depth \\ 0)

  defp branches(")" <> str, acc, branches, 0),
    do: {Enum.reverse([acc | branches]), str}

  defp branches("|" <> str, acc, branches, 0),
    do: branches(str, "", [acc | branches], 0)

  defp branches(")" <> str, acc, branches, n),
    do: branches(str, acc <> ")", branches, n - 1)

  defp branches("(" <> str, acc, branches, n),
    do: branches(str, acc <> "(", branches, n + 1)

  defp branches(<<char::binary-size(1)>> <> str, acc, branches, n),
    do: branches(str, acc <> char, branches, n)
end
