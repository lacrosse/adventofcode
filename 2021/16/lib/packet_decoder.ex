defmodule PacketDecoder do
  def solve do
    File.read!("input.txt")
    |> String.trim()
    |> solve_input()
  end

  @doc """
    ## Examples
      iex> PacketDecoder.solve_input("8A004A801A8002F478")
      {16, 15}
      iex> PacketDecoder.solve_input("620080001611562C8802118E34")
      {12, 46}
      iex> PacketDecoder.solve_input("C0015000016115A2E0802F182340")
      {23, 46}
      iex> PacketDecoder.solve_input("A0016C880162017C3686B18A3D4780")
      {31, 54}
  """
  def solve_input(input) do
    {packet, _} = input |> Packet.parse_hex()
    first = sum_versions(packet)
    second = Packet.eval(packet)

    {first, second}
  end

  defp sum_versions(%Packet{type: Packet.Literal, version: val}), do: val

  defp sum_versions(%Packet{type: _, version: val, value: packets}),
    do: val + Enum.reduce(packets, 0, &(sum_versions(&1) + &2))
end
