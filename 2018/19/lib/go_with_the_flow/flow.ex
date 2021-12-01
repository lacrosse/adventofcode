defmodule GoWithTheFlow.Flow do
  alias ChronalClassification.CPU

  defstruct ip_reg: nil, cpu: nil, program: nil

  @type t :: %__MODULE__{
          ip_reg: CPU.reg(),
          cpu: CPU.t(),
          program: %{optional(non_neg_integer) => CPU.op()}
        }

  @spec init(CPU.reg(), [CPU.op()], keyword) :: t
  def init(ip_reg, program_list, opts \\ []) do
    first_reg_val = Keyword.get(opts, :first_reg_val, 0)

    cpu = CPU.init(6) |> CPU.set_register(0, first_reg_val)

    original_op_list =
      program_list
      |> Enum.with_index()
      |> Enum.map(fn {op, index} -> {index, op} end)

    op_list =
      case Keyword.get(opts, :optimize, false) do
        true ->
          original_op_list
          |> optimize_op_list(ip_reg)

        _ ->
          original_op_list
      end

    program = Enum.into(op_list, %{})

    %__MODULE__{ip_reg: ip_reg, program: program, cpu: cpu}
  end

  @spec execute_until_halt(t) :: CPU.t()
  def execute_until_halt(%__MODULE__{cpu: cpu} = flow) do
    case current_op(flow) do
      nil ->
        cpu

      op ->
        %__MODULE__{flow | cpu: CPU.apply_op(cpu, op)}
        |> incr_instruction_pointer()
        |> execute_until_halt()
    end
  end

  defp current_op(%__MODULE__{program: program} = flow) do
    Map.get(program, instruction_pointer(flow))
  end

  defp instruction_pointer(%__MODULE__{ip_reg: ip_reg, cpu: cpu}),
    do: CPU.get_register(cpu, ip_reg)

  defp incr_instruction_pointer(%__MODULE__{ip_reg: ip_reg, cpu: cpu} = flow),
    do: %__MODULE__{flow | cpu: CPU.incr_register(cpu, ip_reg)}

  defp optimize_op_list(op_list, ip_reg) do
    {head, {loop_reg, loop_start, loop, loop_switch}, tail} = detect_loop(op_list, ip_reg)

    new_loop =
      [
        loop_start | optimize_loop(loop, ip_reg, reg: loop_reg)
      ] ++ loop_switch

    head ++ new_loop ++ tail
  end

  defp optimize_loop(op_list, ip_reg, opts) do
    loop_reg = Keyword.get(opts, :reg)

    {head, {inner_loop_reg, inner_loop_start, inner_loop_body, inner_loop_switch}, tail} =
      detect_loop(op_list, ip_reg)

    {inner_loop_start_index, _} = inner_loop_start

    new_inner_loop_start = {inner_loop_start_index, {:noop, 0, 0, 0}}

    {new_inner_loop_body, _} =
      inner_loop_body
      |> Enum.map_reduce(%{}, fn
        {index, {:mulr, ^loop_reg, ^inner_loop_reg, reg}}, acc ->
          {{index, {:remr, 3, loop_reg, reg}}, Map.put(acc, :reg, reg)}

        {index, {:eqrr, reg, 3, reg}}, %{reg: reg} = acc ->
          {{index, {:eqri, reg, 0, reg}}, acc}

        val, acc ->
          {val, acc}
      end)

    new_inner_loop_switch = Enum.map(inner_loop_switch, fn {i, _} -> {i, {:noop, 0, 0, 0}} end)

    new_inner_loop = [new_inner_loop_start | new_inner_loop_body] ++ new_inner_loop_switch

    head ++ new_inner_loop ++ tail
  end

  defp detect_loop(op_list, ip_reg) do
    {head, [{loop_start_index, {:seti, 1, _, loop_reg}} = loop_start | tail]} =
      Enum.split_while(op_list, fn
        {_, {:seti, 1, _, _}} -> false
        _ -> true
      end)

    {loop, [switch_start | tail]} =
      Enum.split_while(tail, fn
        {_, {:addi, ^loop_reg, 1, ^loop_reg}} -> false
        _ -> true
      end)

    {switch, [loop_end | tail]} =
      Enum.split_while(tail, fn
        {_, {:seti, ^loop_start_index, _, ^ip_reg}} -> false
        _ -> true
      end)

    {head, {loop_reg, loop_start, loop, [switch_start | switch] ++ [loop_end]}, tail}
  end
end
