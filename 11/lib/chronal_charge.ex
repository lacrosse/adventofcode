defmodule ChronalCharge do
  alias ChronalCharge.Grid

  def solve do
    'input.txt'
    |> File.read!()
    |> String.trim_trailing()
    |> String.to_integer()
    |> solve_serial_number()
  end

  @doc """
    iex> ChronalCharge.solve_serial_number(18)
    {33, 45}

    iex> ChronalCharge.solve_serial_number(42)
    {21, 61}
  """
  def solve_serial_number(serial_number) do
    serial_number
    |> Grid.init()
    |> Grid.solve()
  end
end
