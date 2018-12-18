defmodule ChronalClassification.CPU do
  import Bitwise

  @opcode_names [
    :addr,
    :addi,
    :mulr,
    :muli,
    :banr,
    :bani,
    :borr,
    :bori,
    :setr,
    :seti,
    :gtir,
    :gtri,
    :gtrr,
    :eqir,
    :eqri,
    :eqrr
  ]

  @type cpu :: {non_neg_integer(), non_neg_integer(), non_neg_integer(), non_neg_integer()}
  @type op :: atom()
  @type reg :: 0 | 1 | 2 | 3
  @type arg :: reg | non_neg_integer()

  @spec opcode_names() :: [atom()]
  def opcode_names, do: @opcode_names

  @spec apply(cpu(), {op(), arg(), arg(), reg()}) :: cpu()
  def apply(cpu, {:addr, a, b, c}), do: apply_reg_reg(cpu, a, b, c, &+/2)
  def apply(cpu, {:addi, a, b, c}), do: apply_reg_val(cpu, a, b, c, &+/2)
  def apply(cpu, {:mulr, a, b, c}), do: apply_reg_reg(cpu, a, b, c, &*/2)
  def apply(cpu, {:muli, a, b, c}), do: apply_reg_val(cpu, a, b, c, &*/2)
  def apply(cpu, {:banr, a, b, c}), do: apply_reg_reg(cpu, a, b, c, &band/2)
  def apply(cpu, {:bani, a, b, c}), do: apply_reg_val(cpu, a, b, c, &band/2)
  def apply(cpu, {:borr, a, b, c}), do: apply_reg_reg(cpu, a, b, c, &bor/2)
  def apply(cpu, {:bori, a, b, c}), do: apply_reg_val(cpu, a, b, c, &bor/2)
  def apply(cpu, {:setr, a, _, c}), do: set_register(cpu, c, get_register(cpu, a))
  def apply(cpu, {:seti, a, _, c}), do: set_register(cpu, c, a)
  def apply(cpu, {:gtir, a, b, c}), do: apply_binary_ir(cpu, a, b, c, &>/2)
  def apply(cpu, {:gtri, a, b, c}), do: apply_binary_ri(cpu, a, b, c, &>/2)
  def apply(cpu, {:gtrr, a, b, c}), do: apply_binary_rr(cpu, a, b, c, &>/2)
  def apply(cpu, {:eqir, a, b, c}), do: apply_binary_ir(cpu, a, b, c, &==/2)
  def apply(cpu, {:eqri, a, b, c}), do: apply_binary_ri(cpu, a, b, c, &==/2)
  def apply(cpu, {:eqrr, a, b, c}), do: apply_binary_rr(cpu, a, b, c, &==/2)

  defp set_register({_, b, c, d}, 0, val), do: {val, b, c, d}
  defp set_register({a, _, c, d}, 1, val), do: {a, val, c, d}
  defp set_register({a, b, _, d}, 2, val), do: {a, b, val, d}
  defp set_register({a, b, c, _}, 3, val), do: {a, b, c, val}

  defp get_register({val, _, _, _}, 0), do: val
  defp get_register({_, val, _, _}, 1), do: val
  defp get_register({_, _, val, _}, 2), do: val
  defp get_register({_, _, _, val}, 3), do: val

  defp apply_reg_reg(cpu, a, b, c, fun) do
    val_b = get_register(cpu, b)
    apply_reg_val(cpu, a, val_b, c, fun)
  end

  defp apply_reg_val(cpu, a, b, c, fun) do
    val_a = get_register(cpu, a)
    set_register(cpu, c, fun.(val_a, b))
  end

  defp apply_binary_rr(cpu, a, b, c, fun),
    do: apply_binary_ir(cpu, get_register(cpu, a), b, c, fun)

  defp apply_binary_ir(cpu, a, b, c, fun),
    do: apply_binary_ii(cpu, a, get_register(cpu, b), c, fun)

  defp apply_binary_ri(cpu, a, b, c, fun),
    do: apply_binary_ii(cpu, get_register(cpu, a), b, c, fun)

  defp apply_binary_ii(cpu, a, b, c, fun),
    do: set_register(cpu, c, (fun.(a, b) && 1) || 0)
end
