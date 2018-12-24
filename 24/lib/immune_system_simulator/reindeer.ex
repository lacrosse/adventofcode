defmodule ImmuneSystemSimulator.Reindeer do
  defstruct immune: %{}, infection: %{}

  @type group :: map()
  @type system :: %{optional(non_neg_integer) => group}
  @type system_atom :: :immune | :infection
  @type t :: %__MODULE__{immune: system, infection: system}

  @group_regex ~r/\A(\d+) units each with (\d+) hit points(?: \((.+)\))? with an attack that does (\d+) (\w+) damage at initiative (\d+)\z/

  def parse(input) do
    [immune_system, infection] =
      Regex.run(~r/\AImmune System:\n(.+)\nInfection:\n(.+)\z/s, input, capture: :all_but_first)
      |> Enum.map(&parse_system/1)

    %__MODULE__{immune: immune_system, infection: infection}
  end

  @spec boost_immune_system(t, pos_integer) :: t
  def boost_immune_system(%__MODULE__{immune: immune} = reindeer, boost) do
    new_immune =
      immune
      |> Enum.map(fn {index, group} ->
        {index, Map.update!(group, :damage_amount, &(&1 + boost))}
      end)
      |> Enum.into(%{})

    %__MODULE__{reindeer | immune: new_immune}
  end

  @spec remaining_units(t) :: {system_atom, pos_integer}
  def remaining_units(%__MODULE__{} = reindeer) do
    %__MODULE__{immune: new_immune, infection: new_infection} =
      new_reindeer = fight_once(reindeer)

    cond do
      new_immune == %{} ->
        {:infection, new_infection |> Enum.map(&elem(&1, 1)[:unit_count]) |> Enum.sum()}

      new_infection == %{} ->
        {:immune, new_immune |> Enum.map(&elem(&1, 1)[:unit_count]) |> Enum.sum()}

      reindeer == new_reindeer ->
        {:neither, reindeer}

      true ->
        remaining_units(new_reindeer)
    end
  end

  @spec remaining_units_after_sufficient_boost(t) :: pos_integer
  def remaining_units_after_sufficient_boost(%__MODULE__{} = reindeer) do
    {_, units} =
      Stream.iterate(0, &(&1 + 1))
      |> Stream.map(fn boost ->
        boost_immune_system(reindeer, boost) |> remaining_units()
      end)
      |> Enum.find(fn
        {:immune, _} -> true
        _ -> false
      end)

    units
  end

  @spec fight_once(t) :: t
  def fight_once(%__MODULE__{immune: immune, infection: infection} = reindeer) do
    choices = %{
      immune: aim(immune, infection),
      infection: aim(infection, immune)
    }

    immune_list = Enum.map(immune, fn {index, group} -> {index, :immune, group} end)
    infection_list = Enum.map(infection, fn {index, group} -> {index, :infection, group} end)

    (immune_list ++ infection_list)
    |> Enum.sort_by(fn {_, _, group} -> group[:initiative] end)
    |> Enum.reverse()
    |> Enum.map(fn {index, system, _} -> {index, system, choices[system][index]} end)
    |> Enum.filter(fn {_, _, choice} -> choice end)
    |> Enum.reduce(reindeer, fn {group_index, group_system, choice}, current_reindeer ->
      case group_system do
        :immune ->
          case Map.get(current_reindeer.immune, group_index) do
            nil ->
              current_reindeer

            group ->
              %__MODULE__{
                current_reindeer
                | infection:
                    damaged_enemy(
                      current_reindeer.infection,
                      choice,
                      group
                    )
              }
          end

        :infection ->
          case Map.get(current_reindeer.infection, group_index) do
            nil ->
              current_reindeer

            group ->
              %__MODULE__{
                current_reindeer
                | immune:
                    damaged_enemy(
                      current_reindeer.immune,
                      choice,
                      group
                    )
              }
          end
      end
    end)
  end

  defp damaged_enemy(enemy, choice, group) do
    enemy_group = enemy[choice]
    damage = possible_damage(group, enemy_group)
    lost_units = div(damage, enemy_group.health)

    case enemy_group.unit_count - lost_units do
      val when val > 0 ->
        new_enemy_group = %{enemy_group | unit_count: val}
        Map.put(enemy, choice, new_enemy_group)

      _ ->
        Map.delete(enemy, choice)
    end
  end

  defp aim(us, enemies) do
    {choices, _} =
      us
      |> Enum.sort_by(fn {_, group} ->
        {group_effective_power(group), group[:initiative]}
      end)
      |> Enum.reverse()
      |> Enum.map_reduce(enemies, fn {our_index, our_group}, remaining_enemies ->
        projected_enemies =
          remaining_enemies
          |> Enum.map(fn {index, enemy_group} ->
            {index, possible_damage(our_group, enemy_group), group_effective_power(enemy_group),
             enemy_group[:initiative]}
          end)
          |> Enum.filter(fn {_, damage, _, _} -> damage > 0 end)

        case projected_enemies do
          [] ->
            {{our_index, nil}, remaining_enemies}

          _ ->
            {chosen_index, _, _, _} =
              projected_enemies
              |> Enum.max_by(fn {_, damage, power, initiative} -> {damage, power, initiative} end)

            new_enemies = Map.delete(remaining_enemies, chosen_index)
            {{our_index, chosen_index}, new_enemies}
        end
      end)

    choices
    |> Enum.reject(&(elem(&1, 1) == nil))
    |> Enum.into(%{})
  end

  defp group_effective_power(%{unit_count: units, damage_amount: damage}),
    do: units * damage

  defp possible_damage(%{damage_type: damage_type} = us, %{
         immunities: immunities,
         weaknesses: weaknesses
       }) do
    cond do
      MapSet.member?(immunities, damage_type) -> 0
      MapSet.member?(weaknesses, damage_type) -> group_effective_power(us) * 2
      true -> group_effective_power(us)
    end
  end

  defp parse_system(system_str) do
    system_str
    |> String.split(~r/\n/, trim: true)
    |> Enum.map(fn group_str ->
      [unit_count, health, profile, damage_amount, damage_type, initiative] =
        Regex.run(@group_regex, group_str, capture: :all_but_first)

      [unit_count, health, damage_amount, initiative] =
        [unit_count, health, damage_amount, initiative]
        |> Enum.map(&String.to_integer/1)

      immunities =
        case Regex.run(~r/immune to ([\w, ]+)/, profile, capture: :all_but_first) do
          nil -> []
          [immunities_str] -> String.split(immunities_str, ", ") |> Enum.map(&String.to_atom/1)
        end

      weaknesses =
        case Regex.run(~r/weak to ([\w, ]+)/, profile, capture: :all_but_first) do
          nil -> []
          [weaknesses_str] -> String.split(weaknesses_str, ", ") |> Enum.map(&String.to_atom/1)
        end

      %{
        unit_count: unit_count,
        health: health,
        initiative: initiative,
        damage_amount: damage_amount,
        damage_type: String.to_atom(damage_type),
        immunities: MapSet.new(immunities),
        weaknesses: MapSet.new(weaknesses)
      }
    end)
    |> Enum.with_index()
    |> Enum.map(fn {group, index} -> {index, group} end)
    |> Enum.into(%{})
  end
end
