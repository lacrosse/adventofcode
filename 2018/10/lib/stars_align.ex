defmodule StarsAlign do
  alias StarsAlign.Sky

  @star_regex ~r/\Aposition=<\s*(-?\d+),\s*(-?\d+)> velocity=<\s*(-?\d+),\s*(-?\d+)>\z/

  def solve do
    'input.txt'
    |> File.read!()
    |> solve_input()
  end

  @doc """
    iex> input = \"\"\"
    ...> position=< 9,  1> velocity=< 0,  2>
    ...> position=< 7,  0> velocity=<-1,  0>
    ...> position=< 3, -2> velocity=<-1,  1>
    ...> position=< 6, 10> velocity=<-2, -1>
    ...> position=< 2, -4> velocity=< 2,  2>
    ...> position=<-6, 10> velocity=< 2, -2>
    ...> position=< 1,  8> velocity=< 1, -1>
    ...> position=< 1,  7> velocity=< 1,  0>
    ...> position=<-3, 11> velocity=< 1, -2>
    ...> position=< 7,  6> velocity=<-1, -1>
    ...> position=<-2,  3> velocity=< 1,  0>
    ...> position=<-4,  3> velocity=< 2,  0>
    ...> position=<10, -3> velocity=<-1,  1>
    ...> position=< 5, 11> velocity=< 1, -2>
    ...> position=< 4,  7> velocity=< 0, -1>
    ...> position=< 8, -2> velocity=< 0,  1>
    ...> position=<15,  0> velocity=<-2,  0>
    ...> position=< 1,  6> velocity=< 1,  0>
    ...> position=< 8,  9> velocity=< 0, -1>
    ...> position=< 3,  3> velocity=<-1,  1>
    ...> position=< 0,  5> velocity=< 0, -1>
    ...> position=<-2,  2> velocity=< 2,  0>
    ...> position=< 5, -2> velocity=< 1,  2>
    ...> position=< 1,  4> velocity=< 2,  1>
    ...> position=<-2,  7> velocity=< 2, -2>
    ...> position=< 3,  6> velocity=<-1, -1>
    ...> position=< 5,  0> velocity=< 1,  0>
    ...> position=<-6,  0> velocity=< 2,  0>
    ...> position=< 5,  9> velocity=< 1, -2>
    ...> position=<14,  7> velocity=<-2,  0>
    ...> position=<-3,  6> velocity=< 2, -1>
    ...> \"\"\"
    iex> StarsAlign.solve_input(input)
    {3, 7}
  """
  def solve_input(input) do
    input
    |> String.split(~r/\n/, trim: true)
    |> Enum.map(fn str ->
      [x, y, vel_x, vel_y] =
        Regex.run(@star_regex, str, capture: :all_but_first)
        |> Enum.map(&String.to_integer/1)

      {{x, y}, {vel_x, vel_y}}
    end)
    |> Sky.stargaze()
  end
end
