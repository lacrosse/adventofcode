defmodule PacketDecoderTest do
  use ExUnit.Case, async: true
  doctest PacketDecoder

  test "greets the world" do
    assert PacketDecoder.solve() == {971, 831_996_589_851}
  end
end
