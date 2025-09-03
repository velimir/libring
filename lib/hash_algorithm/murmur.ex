defmodule HashRing.HashAlgorithm.Murmur do
  @moduledoc """
  Hash algorithm implementation using MurmurHash3.

  This implementation uses the x86_32 variant of MurmurHash3, providing
  the same ring size as the default Phash2 algorithm (2^32 - 1) but with
  different distribution characteristics.

  MurmurHash is known for good distribution and performance, making it
  suitable for consistent hashing applications.

  ## Dependencies

  This algorithm requires the `:murmur` package to be added to your dependencies:

      {:murmur, "~> 2.0"}

  """

  @behaviour HashRing.HashAlgorithm

  @ring_size trunc(:math.pow(2, 32) - 1)

  @impl true
  def hash(key, _range), do: Murmur.hash_x86_32(key, 0)

  @impl true
  def ring_size() do
    @ring_size
  end
end
