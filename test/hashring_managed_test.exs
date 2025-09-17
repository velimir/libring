defmodule HashRing.ManagedTest do
  use ExUnit.Case, async: true
  doctest HashRing.Managed

  test "callback is called when ring changes" do
    # Create a test process to receive callback
    test_pid = self()

    # Create ring with callback
    {:ok, _pid} = HashRing.Managed.new(:test_callback_ring, [
      on_ring_change: {__MODULE__, :test_callback, [test_pid]}
    ])

    # Add a node to trigger ring change
    :ok = HashRing.Managed.add_node(:test_callback_ring, :test_node)

    # Verify callback was called
    assert_receive {:test_callback, :test_callback_ring, ^test_pid}, 1000
  end

  def test_callback(ring_name, test_pid) do
    send(test_pid, {:test_callback, ring_name, test_pid})
  end

  test "callback is called when new node joins cluster" do
    TestCluster.prepare()
    test_pid = self()

    on_exit(fn -> TestCluster.teardown() end)

    # Create ring with node monitoring and callback
    {:ok, _pid} = HashRing.Managed.new(:test_cluster_ring, [
      monitor_nodes: true,
      on_ring_change: {__MODULE__, :test_callback, [test_pid]}
    ])

    # Clear any initial setup messages
    receive do
      {:test_callback, :test_cluster_ring, ^test_pid} -> :ok
    after
      100 -> :ok
    end

    # Verify initial node count (should be 1 - just the current node)
    initial_nodes = HashRing.Managed.nodes(:test_cluster_ring)
    assert length(initial_nodes) == 1

    # Start a new node to trigger nodeup event
    {:ok, _peer, new_node} = TestCluster.start_node(~c"callback_test_node")

    # Verify callback was called and final node count is correct
    assert_receive {:test_callback, :test_cluster_ring, ^test_pid}, 2000

    final_nodes = HashRing.Managed.nodes(:test_cluster_ring)
    assert length(final_nodes) == 2
    assert new_node in final_nodes
  end
end
