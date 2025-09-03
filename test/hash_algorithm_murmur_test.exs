defmodule HashRing.HashAlgorithm.MurmurTest do
  use ExUnit.Case
  
  @moduletag :murmur

  alias HashRing.HashAlgorithm.Murmur

  test "ring_size/0 returns 2^32 - 1" do
    expected_size = trunc(:math.pow(2, 32) - 1)
    assert Murmur.ring_size() == expected_size
  end

  test "hash/2 returns consistent results" do
    key = "test_key"
    range = Murmur.ring_size()
    
    hash1 = Murmur.hash(key, range)
    hash2 = Murmur.hash(key, range)
    
    assert hash1 == hash2
    assert is_integer(hash1)
  end

  test "hash/2 handles atoms by converting to binary" do
    range = Murmur.ring_size()
    
    atom_hash = Murmur.hash(:test_atom, range)
    binary_hash = Murmur.hash(:erlang.term_to_binary(:test_atom), range)
    
    assert atom_hash == binary_hash
  end

  test "distribution of keys is reasonably uniform" do
    ring = HashRing.new(algorithm: Murmur)
    |> HashRing.add_node("node1")
    |> HashRing.add_node("node2")
    |> HashRing.add_node("node3")

    # Test distribution with 10,000 keys
    results = for i <- 1..10_000 do
      HashRing.key_to_node(ring, i)
    end

    groups = Enum.group_by(results, & &1)
    distribution = Enum.map(groups, fn {_node, values} -> length(values) end)

    # Check that standard deviation is within reasonable bounds (similar to existing tests)
    deviation = (10_000 - std_dev(distribution)) / 10_000
    assert deviation >= 0.90
  end

  defp std_dev(elements) do
    average = Enum.sum(elements) / length(elements)
    variance = Enum.reduce(elements, 0.0, fn x, s -> s + (x - average) * (x - average) end)
    variance = variance / length(elements)
    :math.sqrt(variance)
  end
end