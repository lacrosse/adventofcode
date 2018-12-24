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
    {7, 1}

    iex> input = \"\"\"
    ...> pos=<10,12,12>, r=2
    ...> pos=<12,14,12>, r=2
    ...> pos=<16,12,12>, r=4
    ...> pos=<14,14,14>, r=6
    ...> pos=<50,50,50>, r=200
    ...> pos=<10,10,10>, r=5
    ...> \"\"\"
    iex> ExperimentalEmergencyTeleportation.solve_input(input)
    {6, 36}

  """
  def solve_input(input) do
    swarm =
      input
      |> Swarm.parse()

    first =
      swarm
      |> Swarm.in_range_of_strongest()

    second =
      swarm
      |> Swarm.strongest_signal_distance()

    {first, second}
  end
end
