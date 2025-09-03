defmodule HashRing.HashAlgorithm do
  @moduledoc """
  Behaviour for pluggable hashing algorithms used in hash rings.

  This behaviour allows different hashing algorithms to be used with the hash ring
  implementation. Each algorithm module must implement callbacks for hashing keys
  and providing the ring size.

  ## Example Implementation

      defmodule MyCustomHashAlgorithm do
        @behaviour HashRing.HashAlgorithm

        @impl true
        def hash(key, range) do
          # Your custom hashing implementation
          :erlang.crc32(key) |> rem(range)
        end

        @impl true
        def ring_size() do
          # Size of your hash ring (2^32 - 1 is common)
          trunc(:math.pow(2, 32) - 1)
        end
      end

  """

  @doc """
  Hash a key to a position within the given range.

  ## Parameters

    * `key` - The key to hash
    * `range` - The maximum value for the hash (exclusive)

  ## Returns

  An integer between 0 and `range - 1` (inclusive).
  """
  @callback hash(key :: term(), range :: pos_integer()) :: non_neg_integer()

  @doc """
  Returns the size of the hash ring for this algorithm.

  This determines the total number of possible positions on the ring.
  Common values are 2^32 - 1 or 2^64 - 1.

  ## Returns

  A positive integer representing the ring size.
  """
  @callback ring_size() :: pos_integer()
end