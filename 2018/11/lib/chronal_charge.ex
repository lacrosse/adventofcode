defmodule ChronalCharge do
  alias ChronalCharge.Grid

  def solve do
    'input.txt'
    |> File.read!()
    |> String.trim_trailing()
    |> String.to_integer()
    |> solve_serial_number()
  end

  def solve_serial_number(serial_number) do
    grid =
      serial_number
      |> Grid.init()

    {first, cache} = Grid.solve_for_3(grid)
    {second, _} = Grid.solve_for_all(grid, cache)

    {first, second}
  end
end
