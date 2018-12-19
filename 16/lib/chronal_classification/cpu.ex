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

  @type cpu :: [non_neg_integer]
  @type opcode_name :: atom
  @type reg :: non_neg_integer
  @type arg :: reg | non_neg_integer
  @type op :: {opcode_name, arg, arg, reg}

  @spec opcode_names() :: [atom]
  def opcode_names, do: @opcode_names

  @spec init(pos_integer) :: cpu
  def init(n), do: for(_ <- 1..n, do: 0)

  @spec apply_op(cpu, op) :: cpu
  def apply_op(cpu, {:addr, a, b, c}), do: apply_reg_reg(cpu, a, b, c, &+/2)
  def apply_op(cpu, {:addi, a, b, c}), do: apply_reg_val(cpu, a, b, c, &+/2)
  def apply_op(cpu, {:mulr, a, b, c}), do: apply_reg_reg(cpu, a, b, c, &*/2)
  def apply_op(cpu, {:muli, a, b, c}), do: apply_reg_val(cpu, a, b, c, &*/2)
  def apply_op(cpu, {:banr, a, b, c}), do: apply_reg_reg(cpu, a, b, c, &band/2)
  def apply_op(cpu, {:bani, a, b, c}), do: apply_reg_val(cpu, a, b, c, &band/2)
  def apply_op(cpu, {:borr, a, b, c}), do: apply_reg_reg(cpu, a, b, c, &bor/2)
  def apply_op(cpu, {:bori, a, b, c}), do: apply_reg_val(cpu, a, b, c, &bor/2)
  def apply_op(cpu, {:setr, a, _, c}), do: set_register(cpu, c, get_register(cpu, a))
  def apply_op(cpu, {:seti, a, _, c}), do: set_register(cpu, c, a)
  def apply_op(cpu, {:gtir, a, b, c}), do: apply_binary_ir(cpu, a, b, c, &>/2)
  def apply_op(cpu, {:gtri, a, b, c}), do: apply_binary_ri(cpu, a, b, c, &>/2)
  def apply_op(cpu, {:gtrr, a, b, c}), do: apply_binary_rr(cpu, a, b, c, &>/2)
  def apply_op(cpu, {:eqir, a, b, c}), do: apply_binary_ir(cpu, a, b, c, &==/2)
  def apply_op(cpu, {:eqri, a, b, c}), do: apply_binary_ri(cpu, a, b, c, &==/2)
  def apply_op(cpu, {:eqrr, a, b, c}), do: apply_binary_rr(cpu, a, b, c, &==/2)

  def apply_program(cpu, []), do: cpu

  def apply_program(cpu, [opcode_name | program_tail]),
    do: cpu |> apply_op(opcode_name) |> apply_program(program_tail)

  @spec set_register(cpu, reg, non_neg_integer) :: cpu
  def set_register(cpu, n, val), do: List.replace_at(cpu, n, val)

  @spec get_register(cpu, reg) :: non_neg_integer
  def get_register(cpu, n), do: Enum.at(cpu, n)

  @spec apply_reg_reg(cpu, reg, reg, reg, (non_neg_integer, non_neg_integer -> non_neg_integer)) ::
          cpu
  def apply_reg_reg(cpu, a, b, c, fun) do
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
