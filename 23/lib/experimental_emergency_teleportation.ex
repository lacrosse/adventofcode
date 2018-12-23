defmodule ExperimentalEmergencyTeleportation do
  alias ExperimentalEmergencyTeleportation.Swarm

  def solve do
    "input.txt"
    |> File.read!()
    |> solve_input()
  end

  @doc """
    iex> input = \"\"\"
    ...> pos=<0,0,0>, r=4
    ...> pos=<1,0,0>, r=1
    ...> pos=<4,0,0>, r=3
    ...> pos=<0,2,0>, r=1
    ...> pos=<0,5,0>, r=3
    ...> pos=<0,0,3>, r=1
    ...> pos=<1,1,1>, r=1
    ...> pos=<1,1,2>, r=1
    ...> pos=<1,3,1>, r=1
    ...> \"\"\"
    iex> ExperimentalEmergencyTeleportation.solve_input(input)
    7
  """
  def solve_input(input) do
    input
    |> Swarm.parse()
    |> Swarm.in_range_of_strongest()
  end
end
