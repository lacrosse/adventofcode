defmodule ChronalClassification do
  alias ChronalClassification.CPU
  @before_regex ~r/\ABefore:\s*\[(\d), (\d), (\d), (\d)\]\z/
  @after_regex ~r/\AAfter:\s*\[(\d), (\d), (\d), (\d)\]\z/

  def solve do
    "input.txt"
    |> File.read!()
    |> solve_input()
  end

  def solve_input(full_input) do
    [samples, _program] =
      full_input
      |> String.split(~r/\n\n\n/)

    samples
    |> String.split(~r/\n/, trim: true)
    |> Enum.chunk_every(3)
    |> Enum.map(fn [before_op, op, after_op] ->
      cpu =
        Regex.run(@before_regex, before_op, capture: :all_but_first)
        |> Enum.map(&String.to_integer/1)
        |> List.to_tuple()

      [_a, b, c, d] =
        op
        |> String.split()
        |> Enum.map(&String.to_integer/1)

      cpu_after =
        Regex.run(@after_regex, after_op, capture: :all_but_first)
        |> Enum.map(&String.to_integer/1)
        |> List.to_tuple()

      CPU.opcode_names()
      |> Enum.count(fn opcode_name ->
        CPU.apply(cpu, {opcode_name, b, c, d}) == cpu_after
      end)
    end)
    |> Enum.count(fn likeness -> likeness >= 3 end)
  end
end
