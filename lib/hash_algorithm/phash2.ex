defmodule HashRing.HashAlgorithm.Phash2 do
  @moduledoc """
  Default hash algorithm implementation using Erlang's `:erlang.phash2/2`.

  This is the original hashing algorithm used by libring, providing good
  distribution characteristics and compatibility with the existing API.

  The ring size is 2^32 - 1, which provides a large keyspace for consistent
  hashing while being efficiently computed.
  """

  @behaviour HashRing.HashAlgorithm

  @ring_size trunc(:math.pow(2, 32) - 1)

  @impl true
  def hash(key, range) do
    :erlang.phash2(key, range)
  end

  @impl true
  def ring_size() do
    @ring_size
  end
end
