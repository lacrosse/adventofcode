defmodule Snailfish.Composite do
  alias Snailfish.Number

  defstruct left: nil, right: nil

  @type t() :: %__MODULE__{left: Number.t(), right: Number.t()}

  def add(n1, n2), do: reduce(%__MODULE__{left: n1, right: n2})

  def reduce(sn) do
    case Number.explode(sn, 4) do
      :step ->
        case Number.split(sn) do
          :step -> sn
          {:halt, val} -> reduce(val)
        end

      {:halt, val, _, _} ->
        reduce(val)
    end
  end

  @doc """
  ## Examples
    iex> "[[[[[9,8],1],2],3],4]" |> Snailfish.Composite.from_string() |> Snailfish.Number.to_tuple()
    {{{{{9, 8}, 1}, 2}, 3}, 4}
  """
  @spec from_string(binary()) :: Composite.t()
  def from_string(str, stack \\ [])

  def from_string("", [num]),
    do: num

  def from_string("[" <> tail, stack),
    do: from_string(tail, stack)

  def from_string("]" <> tail, [one, two | stack]),
    do: from_string(tail, [%__MODULE__{left: two, right: one} | stack])

  def from_string("," <> tail, stack),
    do: from_string(tail, stack)

  def from_string(<<char::binary-size(1)>> <> tail, stack),
    do: from_string(tail, [String.to_integer(char) | stack])
end
