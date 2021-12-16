defmodule Packet do
  defstruct version: nil, type: nil, value: nil

  @types [Sum, Product, Min, Max, Literal, GT, LT, EQ]
         |> Enum.with_index(&{&2, Module.concat(__MODULE__, &1)})
         |> Enum.into(%{})

  @doc """
  ## Examples
    iex> "C200B40A82" |> Packet.parse_hex() |> elem(0) |> Packet.eval()
    3
    iex> "04005AC33890" |> Packet.parse_hex() |> elem(0) |> Packet.eval()
    54
    iex> "880086C3E88112" |> Packet.parse_hex() |> elem(0) |> Packet.eval()
    7
    iex> "CE00C43D881120" |> Packet.parse_hex() |> elem(0) |> Packet.eval()
    9
    iex> "D8005AC2A8F0" |> Packet.parse_hex() |> elem(0) |> Packet.eval()
    1
    iex> "F600BC2D8F" |> Packet.parse_hex() |> elem(0) |> Packet.eval()
    0
    iex> "9C005AC2F8F0" |> Packet.parse_hex() |> elem(0) |> Packet.eval()
    0
    iex> "9C0141080250320F1802104A08" |> Packet.parse_hex() |> elem(0) |> Packet.eval()
    1
  """
  def eval(%__MODULE__{type: __MODULE__.Literal, value: value}),
    do: value

  def eval(%__MODULE__{type: operator_type, value: packets}),
    do: packets |> Enum.map(&eval/1) |> reduce_with_operator(operator_type)

  def parse_hex(string) do
    string
    |> :binary.decode_hex()
    |> :binary.bin_to_list()
    |> Enum.flat_map(fn num ->
      l = Integer.digits(num, 2)
      List.duplicate(0, 8 - length(l)) ++ l
    end)
    |> Enum.join()
    |> parse()
  end

  @doc """
  ## Examples
    iex> Packet.parse("110100101111111000101000")
    {%Packet{type: Packet.Literal, version: 6, value: 2021}, "000"}
    iex> Packet.parse("00111000000000000110111101000101001010010001001000000000")
    { %Packet{type: Packet.LT, version: 1, value: [
        %Packet{type: Packet.Literal, version: 6, value: 10},
        %Packet{type: Packet.Literal, version: 2, value: 20}
      ]},
      "0000000" }
    iex> Packet.parse("11101110000000001101010000001100100000100011000001100000")
    { %Packet{type: Packet.Max, version: 7, value: [
        %Packet{type: Packet.Literal, version: 2, value: 1},
        %Packet{type: Packet.Literal, version: 4, value: 2},
        %Packet{type: Packet.Literal, version: 1, value: 3}
      ]},
      "00000" }
  """
  def parse(<<version_string::binary-size(3), type_string::binary-size(3), data::binary>>) do
    version = to_int(version_string)
    type_int = to_int(type_string)

    type = @types[type_int]

    case type do
      __MODULE__.Literal ->
        {value, tail} = parse_value(type, data)
        {%Packet{type: type, version: version, value: value}, tail}

      _ ->
        {packets, tail} =
          case data do
            <<"0", length_string::binary-size(15), tail::binary>> ->
              bit_length = to_int(length_string)
              <<packets_string::binary-size(bit_length), tail::binary>> = tail

              packets =
                packets_string
                |> Stream.unfold(fn
                  "" -> nil
                  packets_tail -> parse(packets_tail)
                end)
                |> Enum.to_list()

              {packets, tail}

            <<"1", length_string::binary-size(11), tail::binary>> ->
              parse_packets(tail, to_int(length_string))
          end

        {%Packet{type: type, version: version, value: packets}, tail}
    end
  end

  defp parse_packets(string, 0), do: {[], string}

  defp parse_packets(string, n) do
    {packet, tail} = parse(string)
    {packets, tail} = parse_packets(tail, n - 1)
    {[packet | packets], tail}
  end

  defp parse_value(type, string, acc \\ 0)

  defp parse_value(__MODULE__.Literal, <<"1", hex::binary-size(4), tail::binary>>, acc),
    do: parse_value(__MODULE__.Literal, tail, (acc + to_int(hex)) * 16)

  defp parse_value(__MODULE__.Literal, <<"0", hex::binary-size(4), tail::binary>>, acc),
    do: {acc + to_int(hex), tail}

  defp parse_value(__MODULE__.Operator, str, _acc) do
    str
  end

  def reduce_with_operator(vals, __MODULE__.Sum), do: vals |> Enum.reduce(0, &+/2)
  def reduce_with_operator(vals, __MODULE__.Product), do: vals |> Enum.reduce(1, &*/2)
  def reduce_with_operator(vals, __MODULE__.Min), do: vals |> Enum.reduce(&min/2)
  def reduce_with_operator(vals, __MODULE__.Max), do: vals |> Enum.reduce(&max/2)
  def reduce_with_operator([one, two], __MODULE__.GT) when one > two, do: 1
  def reduce_with_operator(_, __MODULE__.GT), do: 0
  def reduce_with_operator([one, two], __MODULE__.LT) when one < two, do: 1
  def reduce_with_operator(_, __MODULE__.LT), do: 0
  def reduce_with_operator([one, two], __MODULE__.EQ) when one == two, do: 1
  def reduce_with_operator(_, __MODULE__.EQ), do: 0

  defp to_int(str), do: str |> String.to_integer(2)
end
