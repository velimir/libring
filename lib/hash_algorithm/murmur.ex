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
  def hash(key, _range) do
    # Convert atoms to binaries for better distribution (like phash2)
    key = if is_atom(key), do: :erlang.term_to_binary(key), else: key

    # Use MurmurHash3 x86_32 variant with seed 0
    # This returns a 32-bit value which fits perfectly in our ring size
    Murmur.hash_x86_32(key, 0)
  end

  @impl true
  def ring_size() do
    @ring_size
  end
end
