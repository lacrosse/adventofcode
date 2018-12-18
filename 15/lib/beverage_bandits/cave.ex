defmodule BeverageBandits.Cave do
  alias BeverageBandits.{Geometry, Fighter}

  defstruct walls: MapSet.new(), fighters: %{}

  @type t() :: %__MODULE__{walls: map(), fighters: map()}

  @spec init(String.t()) :: t()
  def init(input) do
    indexed_input =
      input
      |> String.split(~r/\n/, trim: true)
      |> Stream.map(fn line ->
        line
        |> String.codepoints()
        |> Stream.with_index()
      end)
      |> Stream.with_index()

    objects =
      for {row, y} <- indexed_input,
          {object, x} <- row,
          do: {{x, y}, object}

    {walls, fighters} =
      Enum.reduce(objects, {%MapSet{}, %{}}, fn {coords, object}, {walls, frs} ->
        case object do
          "#" -> {MapSet.put(walls, coords), frs}
          "." -> {walls, frs}
          "E" -> {walls, Map.put(frs, coords, %Fighter{gender: :elf})}
          "G" -> {walls, Map.put(frs, coords, %Fighter{gender: :goblin})}
        end
      end)

    %__MODULE__{walls: walls, fighters: fighters}
  end

  @spec winning_battle_result(t(), pos_integer()) :: pos_integer()
  def winning_battle_result(%__MODULE__{} = cave, elf_hit_severity \\ 4) do
    case try_to_win_battle(cave, elf_hit_severity) do
      {:ok, battle_result} ->
        battle_result

      :fail ->
        winning_battle_result(cave, elf_hit_severity + 1)
    end
  end

  @spec battle_result(t()) :: pos_integer()
  def battle_result(%__MODULE__{} = cave) do
    {:ok, winners, rounds} = battle(cave, elf_hit_severity: 3)

    winners_health =
      winners
      |> Enum.map(fn %Fighter{health: health} -> health end)
      |> Enum.sum()

    rounds * winners_health
  end

  defp try_to_win_battle(%__MODULE__{} = cave, elf_hit_severity) do
    case battle(cave, elf_hit_severity: elf_hit_severity, save_elves: true) do
      {:ok, winners, rounds} ->
        winners_health =
          winners
          |> Enum.map(fn %Fighter{health: health} -> health end)
          |> Enum.sum()

        {:ok, rounds * winners_health}

      :fail ->
        :fail
    end
  end

  defp battle(%__MODULE__{} = cave, opts, rounds \\ 0) do
    if System.get_env("DEBUG"), do: visualize(cave, rounds)

    case fight_round(cave, opts) do
      {:fight, new_cave, deaths} ->
        if opts[:save_elves] && Enum.find(deaths, fn d -> d == :elf end) do
          :fail
        else
          battle(new_cave, opts, rounds + 1)
        end

      {:victory, winners, deaths} ->
        if opts[:save_elves] && Enum.find(deaths, fn d -> d == :elf end) do
          :fail
        else
          {:ok, winners, rounds}
        end
    end
  end

  defp fight_round(%__MODULE__{fighters: fighters} = cave, opts) do
    pre_fight_fighters_coords =
      fighters
      |> Enum.map(&elem(&1, 0))
      |> Enum.sort_by(&Geometry.reading_order/1)

    case act_on(pre_fight_fighters_coords, {:cont, cave}, opts) do
      {:victory, last_cave, deaths} ->
        {:victory, last_cave.fighters |> Enum.map(&elem(&1, 1)), deaths}

      {:fight, new_cave, deaths} ->
        {:fight, new_cave, deaths}
    end
  end

  defp act_on(coords, state, deaths \\ [], opts)
  defp act_on(_, {:halt, val}, deaths, _), do: {:victory, val, deaths}
  defp act_on([], {:cont, cave}, deaths, _), do: {:fight, cave, deaths}

  defp act_on([actor_coords | tail], {:cont, cave}, deaths, opts) do
    case act(cave, actor_coords, opts) do
      :victory ->
        act_on(tail, {:halt, cave}, deaths, opts)

      {:fight, new_cave} ->
        act_on(tail, {:cont, new_cave}, deaths, opts)

      {:fight, new_cave, {death_coords, death_gender}} ->
        tail
        |> Enum.reject(fn coords -> coords == death_coords end)
        |> act_on({:cont, new_cave}, [death_gender | deaths], opts)
    end
  end

  defp act(%__MODULE__{fighters: fighters} = cave, actor_coords, opts) do
    case Map.pop(fighters, actor_coords) do
      {nil, _} ->
        {:fight, cave}

      {actor, actorless_fighters} ->
        actorless_cave = %__MODULE__{cave | fighters: actorless_fighters}

        case move(actorless_cave, actor, actor_coords) do
          {:fight, moved_coords} ->
            case fight(actorless_cave, actor, moved_coords, opts) do
              {:tough, fought_actorless_cave} ->
                restored_fighters = fought_actorless_cave.fighters |> Map.put(moved_coords, actor)
                {:fight, %__MODULE__{fought_actorless_cave | fighters: restored_fighters}}

              {:easy, fought_actorless_cave, death} ->
                restored_fighters = fought_actorless_cave.fighters |> Map.put(moved_coords, actor)

                {:fight, %__MODULE__{fought_actorless_cave | fighters: restored_fighters}, death}
            end

          :victory ->
            :victory
        end
    end
  end

  defp move(%__MODULE__{walls: walls, fighters: fighters}, %Fighter{gender: gender}, coords) do
    enemy = enemy(gender)

    enemies =
      fighters
      |> Enum.filter(fn {_, %Fighter{gender: gender}} -> gender == enemy end)

    case enemies do
      [] ->
        :victory

      _ ->
        enemy_coords =
          enemies
          |> Enum.map(&elem(&1, 0))
          |> Enum.into(%MapSet{})

        fighter_coords =
          fighters
          |> Enum.map(&elem(&1, 0))
          |> Enum.into(%MapSet{})

        obstacles = MapSet.union(walls, fighter_coords)

        {:fight, Fighter.move_towards_enemies(coords, enemy_coords, obstacles)}
    end
  end

  defp fight(%__MODULE__{fighters: fighters} = cave, %Fighter{gender: gender}, coords, opts) do
    enemy = enemy(gender)

    enemies =
      coords
      |> Geometry.neighbors()
      |> Enum.flat_map(fn coords ->
        case Map.get(fighters, coords) do
          %Fighter{gender: ^enemy} = fighter -> [{coords, fighter}]
          _ -> []
        end
      end)

    case enemies do
      [] ->
        {:tough, cave}

      _ ->
        {_, weakest_enemies} =
          enemies
          |> Enum.group_by(fn {_, %Fighter{health: health}} -> health end)
          |> Enum.min_by(fn {health, _} -> health end)

        {coords, enemy} =
          weakest_enemies
          |> Enum.min_by(fn {coords, _} -> Geometry.reading_order(coords) end)

        severity =
          case gender do
            :goblin -> 3
            :elf -> opts[:elf_hit_severity]
          end

        case Fighter.hit(enemy, severity) do
          {:alive, new_enemy} ->
            {:tough, %__MODULE__{cave | fighters: Map.put(fighters, coords, new_enemy)}}

          :dead ->
            {:easy, %__MODULE__{cave | fighters: Map.delete(fighters, coords)},
             {coords, enemy.gender}}
        end
    end
  end

  defp enemy(:elf), do: :goblin
  defp enemy(:goblin), do: :elf

  defp visualize(%__MODULE__{walls: walls, fighters: fighters}, rounds) do
    walls_map =
      walls
      |> Enum.map(fn coords -> {coords, :wall} end)
      |> Enum.into(%{})

    objects = Map.merge(fighters, walls_map)

    {{{min_x, _}, _}, {{max_x, _}, _}} = Enum.min_max_by(objects, fn {{x, _}, _} -> x end)
    {{{_, min_y}, _}, {{_, max_y}, _}} = Enum.min_max_by(objects, fn {{_, y}, _} -> y end)

    IO.puts("After round #{rounds}")

    [" " | for(x <- min_x..max_x, do: rem(x, 10))]
    |> Enum.join()
    |> IO.puts()

    for y <- min_y..max_y do
      row =
        for x <- min_x..max_x do
          case Map.get(objects, {x, y}) do
            nil -> {".", nil}
            :wall -> {"#", nil}
            %Fighter{gender: :elf, health: health} -> {"E", health}
            %Fighter{gender: :goblin, health: health} -> {"G", health}
          end
        end

      cave_string =
        row
        |> Enum.map(&elem(&1, 0))
        |> Enum.join()

      desc =
        row
        |> Enum.filter(&elem(&1, 1))
        |> Enum.map(fn {g, h} -> "#{g}#{h}" end)
        |> Enum.join(" ")

      IO.puts("#{rem(y, 10)}#{cave_string} #{desc}")
    end

    IO.puts("")
    :timer.sleep(100)
  end
end
