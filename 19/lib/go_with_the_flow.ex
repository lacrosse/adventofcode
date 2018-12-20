defmodule GoWithTheFlow do
  alias __MODULE__.Flow
  alias ChronalClassification.CPU

  @spec solve :: {non_neg_integer, non_neg_integer}
  def solve do
    "input_original.txt"
    |> File.read!()
    |> solve_input()
  end

  @spec solve_input(binary) :: {non_neg_integer, non_neg_integer}
  def solve_input(input) do
    [ip_reg_input | program_input] =
      input
      |> String.split(~r/\n/, trim: true)

    [ip_reg] =
      Regex.run(~r/\A#ip (\d+)\z/, ip_reg_input, capture: :all_but_first)
      |> Enum.map(&String.to_integer/1)

    program =
      program_input
      |> Enum.map(fn line ->
        [opcode_str | arg_strs] =
          Regex.run(~r/\A(\w+) (\d+) (\d+) (\d+)\z/, line, capture: :all_but_first)

        opcode = String.to_atom(opcode_str)
        [a, b, c] = Enum.map(arg_strs, &String.to_integer/1)
        {opcode, a, b, c}
      end)

    first =
      Flow.init(ip_reg, program)
      |> Flow.execute_until_halt()
      |> CPU.get_register(0)

    second =
      Flow.init(ip_reg, program, 1)
      |> Flow.execute_until_halt()
      |> CPU.get_register(0)

    {first, second}
  end
end
