defmodule MineCartMadness do
  alias MineCartMadness.Field

  def solve do
    'input.txt'
    |> File.read!()
    |> solve_input()
  end

  @doc """
    # /->-\
    # |   |  /----\
    # | /-+--+-\  |
    # | | |  | v  |
    # \-+-/  \-+--/
    #   \------/

    iex> input = \"\"\"
    ...> /->-\\\\
    ...> |   |  /----\\\\
    ...> | /-+--+-\\\\  |
    ...> | | |  | v  |
    ...> \\\\-+-/  \\\\-+--/
    ...>   \\\\------/
    ...> \"\"\"
    iex> input |> MineCartMadness.solve_input()
    {{7, 3}, nil}
  """
  def solve_input(input) do
    field =
      input
      |> Field.init()

    {Field.first_crash_location(field), Field.last_cart_location(field)}
  end
end
