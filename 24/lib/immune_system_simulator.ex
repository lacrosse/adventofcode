defmodule ImmuneSystemSimulator do
  alias ImmuneSystemSimulator.Reindeer

  def solve do
    "input.txt"
    |> File.read!()
    |> solve_input()
  end

  @doc """
    iex> input = \"\"\"
    ...> Immune System:
    ...> 17 units each with 5390 hit points (weak to radiation, bludgeoning) with an attack that does 4507 fire damage at initiative 2
    ...> 989 units each with 1274 hit points (immune to fire; weak to bludgeoning, slashing) with an attack that does 25 slashing damage at initiative 3
    ...>
    ...> Infection:
    ...> 801 units each with 4706 hit points (weak to radiation) with an attack that does 116 bludgeoning damage at initiative 1
    ...> 4485 units each with 2961 hit points (immune to radiation; weak to fire, cold) with an attack that does 12 slashing damage at initiative 4
    ...> \"\"\"
    iex> ImmuneSystemSimulator.solve_input(input)
    5216
  """
  def solve_input(input) do
    input
    |> Reindeer.parse()
    |> Reindeer.remaining_units()
  end
end
