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
    [samples, program_input] =
      full_input
      |> String.split(~r/\n\n\n/)

    opcodes_to_likely_names =
      samples
      |> String.split(~r/\n/, trim: true)
      |> Enum.chunk_every(3)
      |> Enum.map(fn [before_op, op, after_op] ->
        cpu =
          Regex.run(@before_regex, before_op, capture: :all_but_first)
          |> Enum.map(&String.to_integer/1)
          |> Enum.with_index()
          |> Enum.map(fn {val, reg} -> {reg, val} end)
          |> Enum.into(%{})

        [opcode, a, b, c] =
          op
          |> String.split()
          |> Enum.map(&String.to_integer/1)

        cpu_after =
          Regex.run(@after_regex, after_op, capture: :all_but_first)
          |> Enum.map(&String.to_integer/1)
          |> Enum.with_index()
          |> Enum.map(fn {val, reg} -> {reg, val} end)
          |> Enum.into(%{})

        likely_opcode_names =
          CPU.opcode_names()
          |> Enum.filter(fn opcode_name ->
            CPU.apply_op(cpu, {opcode_name, a, b, c}) == cpu_after
          end)
          |> Enum.into(%MapSet{})

        {opcode, likely_opcode_names}
      end)

    first =
      opcodes_to_likely_names
      |> Enum.count(fn {_, likely_names} -> MapSet.size(likely_names) >= 3 end)

    opcodes_to_names = shake(opcodes_to_likely_names)

    program =
      program_input
      |> String.split(~r/\n/, trim: true)
      |> Enum.map(fn line ->
        [opcode, a, b, c] =
          line
          |> String.split()
          |> Enum.map(&String.to_integer/1)

        {Map.fetch!(opcodes_to_names, opcode), a, b, c}
      end)

    second =
      CPU.init(4)
      |> CPU.apply_program(program)
      |> CPU.get_register(0)

    {first, second}
  end

  defp shake(opcodes_to_likely_names) do
    aggregated =
      opcodes_to_likely_names
      |> Enum.group_by(&elem(&1, 0), &elem(&1, 1))
      |> Enum.map(fn {opcode, guess_sets} ->
        intersection = Enum.reduce(guess_sets, &MapSet.intersection(&2, &1))
        {opcode, intersection}
      end)
      |> Enum.into(%{})

    do_shake(aggregated, %{})
  end

  defp do_shake(map, settled) when map_size(map) == 0, do: settled

  defp do_shake(opcodes_to_guesses, settled) do
    certains =
      opcodes_to_guesses
      |> Enum.filter(fn {_, guesses} -> MapSet.size(guesses) == 1 end)
      |> Enum.map(fn {opcode, guesses} ->
        [name] = guesses |> MapSet.to_list()
        {opcode, name}
      end)

    new_settled =
      certains
      |> Enum.reduce(settled, fn {opcode, name}, current_settled ->
        Map.put(current_settled, opcode, name)
      end)

    certain_opcodes = Enum.map(certains, &elem(&1, 0))
    certain_names = Enum.map(certains, &elem(&1, 1)) |> Enum.into(%MapSet{})

    new_opcodes_to_guesses =
      opcodes_to_guesses
      |> Map.drop(certain_opcodes)
      |> Enum.map(fn {opcode, guesses} ->
        {opcode, MapSet.difference(guesses, certain_names)}
      end)
      |> Enum.into(%{})

    do_shake(new_opcodes_to_guesses, new_settled)
  end
end
