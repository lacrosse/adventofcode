defprotocol Snailfish.Number do
  @doc """
  ## Examples
    iex> input = "[[[[6,6],[7,6]],[[7,7],[7,0]]],[[[7,7],[7,7]],[[7,8],[9,9]]]]"
    iex> input |> Snailfish.Composite.from_string() |> Snailfish.Number.magnitude()
    4140
  """
  def magnitude(val)

  def explode(val, level)

  def split(val)

  def add_int_to_leftmost(val, int)

  def add_int_to_rightmost(val, int)

  def to_tuple(val)
end

defimpl Snailfish.Number, for: Integer do
  def magnitude(val), do: val

  def explode(_, _), do: :step

  def split(val) when val > 9,
    do: {:halt, %Snailfish.Composite{left: div(val, 2), right: div(val + 1, 2)}}

  def split(_), do: :step

  def add_int_to_leftmost(val, int), do: val + int

  def add_int_to_rightmost(val, int), do: val + int

  def to_tuple(val), do: val
end

defimpl Snailfish.Number, for: Snailfish.Composite do
  alias Snailfish.{Number, Composite}

  def magnitude(%Composite{left: left, right: right}),
    do: Number.magnitude(left) * 3 + Number.magnitude(right) * 2

  def explode(%Composite{left: left, right: right}, 0), do: {:halt, 0, left, right}

  def explode(%Composite{left: left, right: right}, level) do
    case Number.explode(left, level - 1) do
      :step ->
        case Number.explode(right, level - 1) do
          :step ->
            :step

          {:halt, new_right, rem_left, rem_right} ->
            {:halt,
             %Composite{
               left: Number.add_int_to_rightmost(left, rem_left),
               right: new_right
             }, 0, rem_right}
        end

      {:halt, new_left, rem_left, rem_right} ->
        {:halt,
         %Composite{
           left: new_left,
           right: Number.add_int_to_leftmost(right, rem_right)
         }, rem_left, 0}
    end
  end

  def split(%Composite{left: left, right: right}) do
    case Number.split(left) do
      :step ->
        case Number.split(right) do
          :step -> :step
          {:halt, new_right} -> {:halt, %Composite{left: left, right: new_right}}
        end

      {:halt, new_left} ->
        {:halt, %Composite{left: new_left, right: right}}
    end
  end

  def add_int_to_leftmost(%Composite{left: left, right: right}, int),
    do: %Composite{
      left: Number.add_int_to_leftmost(left, int),
      right: right
    }

  def add_int_to_rightmost(%Composite{left: left, right: right}, int),
    do: %Composite{
      left: left,
      right: Number.add_int_to_rightmost(right, int)
    }

  def to_tuple(%Composite{left: left, right: right}),
    do: {Number.to_tuple(left), Number.to_tuple(right)}
end
