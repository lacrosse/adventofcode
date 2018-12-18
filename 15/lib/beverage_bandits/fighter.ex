defmodule BeverageBandits.Fighter do
  alias BeverageBandits.Geometry

  defstruct health: 200, gender: nil

  @type t() :: %__MODULE__{health: pos_integer(), gender: :elf | :goblin}

  @doc """
    iex> obstacles = MapSet.new([
    ...>   {1, 0}, {2, -1}, {3, 0},
    ...>   {4, 1}, {5, 2}, {4, 3},
    ...>   {3, 4}, {2, 5}, {1, 4},
    ...>   {0, 3}, {-1, 2}, {0, 1},
    ...>   {2, 2}
    ...> ])
    iex> BeverageBandits.Fighter.move_towards_enemies({1, 2}, MapSet.new([{3, 2}]), obstacles)
    {1, 1}
    iex> BeverageBandits.Fighter.move_towards_enemies({1, 2}, MapSet.new([{4, 2}]), obstacles)
    {1, 1}
    iex> BeverageBandits.Fighter.move_towards_enemies({1, 2}, MapSet.new([{4, 2}]), MapSet.put(obstacles, {3, 2}))
    {1, 2}
    iex> BeverageBandits.Fighter.move_towards_enemies({2, 3}, MapSet.new([{2, 1}]), obstacles)
    {1, 3}
    iex> BeverageBandits.Fighter.move_towards_enemies({2, 3}, MapSet.new([{2, 0}]), obstacles)
    {1, 3}
    iex> BeverageBandits.Fighter.move_towards_enemies({3, 2}, MapSet.new([{1, 2}]), obstacles)
    {3, 1}
    iex> BeverageBandits.Fighter.move_towards_enemies({3, 2}, MapSet.new([{0, 2}]), obstacles)
    {3, 1}
    iex> BeverageBandits.Fighter.move_towards_enemies({2, 1}, MapSet.new([{2, 3}]), obstacles)
    {1, 1}
    iex> BeverageBandits.Fighter.move_towards_enemies({2, 1}, MapSet.new([{2, 4}]), obstacles)
    {1, 1}

    iex> BeverageBandits.Fighter.move_towards_enemies({0, 0}, MapSet.new([{2, 4}]), MapSet.new([{0, 1}, {1, 3}, {2, 3}]))
    {-1, 0}
  """
  def move_towards_enemies(fighter, targets, obstacles) do
    in_range =
      targets
      |> Enum.flat_map(&Geometry.neighbors(&1, obstacles))
      |> Enum.into(%MapSet{})
      |> MapSet.difference(obstacles)

    case find_nearest_reachable_path(fighter, in_range, obstacles) do
      :unreachable -> fighter
      [^fighter] -> fighter
      [^fighter, step | _] -> step
    end
  end

  @spec hit(t()) :: :dead | {:alive, t()}
  def hit(%__MODULE__{health: health} = fighter) when health > 3,
    do: {:alive, %__MODULE__{fighter | health: health - 3}}

  def hit(%__MODULE__{}),
    do: :dead

  @doc """
    iex> BeverageBandits.Fighter.find_nearest_reachable_path({0, 0}, MapSet.new([{1, 4}]), MapSet.new([{0, 1}, {1, 3}, {2, 3}]))
    [{0, 0}, {-1, 0}, {-1, 1}, {-1, 2}, {0, 2}, {0, 3}, {0, 4}, {1, 4}]

    iex> BeverageBandits.Fighter.find_nearest_reachable_path({2, 2}, MapSet.new([{0, 0}]), %MapSet{})
    [{2, 2}, {2, 1}, {2, 0}, {1, 0}, {0, 0}]

    iex> BeverageBandits.Fighter.find_nearest_reachable_path({0, 0}, MapSet.new([{2, 2}]), %MapSet{})
    [{0, 0}, {1, 0}, {2, 0}, {2, 1}, {2, 2}]

    iex> BeverageBandits.Fighter.find_nearest_reachable_path({2, 0}, MapSet.new([{0, 2}]), %MapSet{})
    [{2, 0}, {1, 0}, {0, 0}, {0, 1}, {0, 2}]

    iex> BeverageBandits.Fighter.find_nearest_reachable_path({0, 2}, MapSet.new([{2, 0}]), %MapSet{})
    [{0, 2}, {0, 1}, {0, 0}, {1, 0}, {2, 0}]
  """
  @spec find_nearest_reachable_path(
          Geometry.coords(),
          Geometry.coords_set(),
          Geometry.coords_set()
        ) :: :unreachable | Geometry.path()
  def find_nearest_reachable_path(from, tos, obstacles),
    do: extend_reach(tos, obstacles, [[from]], MapSet.new([from]))

  @spec extend_reach(
          Geometry.coords_set(),
          Geometry.coords_set(),
          [Geometry.path()],
          Geometry.coords_set()
        ) :: :unreachable | Geometry.path()
  def extend_reach(_, _, [], _), do: :unreachable

  def extend_reach(tos, obstacles, paths_so_far, visited) do
    case Enum.filter(paths_so_far, fn [dest | _] -> MapSet.member?(tos, dest) end) do
      [] ->
        {new_dest_paths, new_visited} =
          paths_so_far
          |> Enum.flat_map_reduce(visited, fn [last_step | _] = path, current_visited ->
            dests = Geometry.neighbors(last_step, MapSet.union(obstacles, current_visited))

            new_visited = Enum.reduce(dests, current_visited, &MapSet.put(&2, &1))

            {Enum.map(dests, &{&1, path}), new_visited}
          end)

        new_paths = Enum.map(new_dest_paths, fn {dest, path} -> [dest | path] end)

        extend_reach(tos, obstacles, new_paths, new_visited)

      reached_paths ->
        reached_paths
        |> Enum.min_by(fn [dest | _] -> Geometry.reading_order(dest) end)
        |> Enum.reverse()
    end
  end
end
