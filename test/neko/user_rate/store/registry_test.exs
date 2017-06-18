defmodule Neko.UserRate.Store.RegistryTest do
  use ExUnit.Case, async: true

  alias Neko.UserRate
  alias Neko.UserRate.Store
  alias Neko.UserRate.Store.Registry, as: StoreRegistry

  setup context do
    # context.test - name of specific test
    # (say, 'creates store by user_id')
    {:ok, _} = StoreRegistry.start_link(context.test)
    # use registry by its name, not pid
    {:ok, registry: context.test}
  end

  # NOTE: make sure test descriptions are unique across all
  #       tests since they are used as registry names -
  #       otherwise you'll get this error when trying to registry:
  #
  #       no match of right hand side value: {:error, {:already_started, ...}}
  test "creates user rate store by user id", %{registry: registry} do
    user_id = 1
    id = 2
    user_rate = %UserRate{id: id, score: 10}

    StoreRegistry.create(registry, user_id)
    assert {:ok, store} = StoreRegistry.lookup(registry, user_id)

    Store.put(store, id, user_rate)
    assert Store.get(store, id) == user_rate
  end

  test "removes user rate stores on exit", %{registry: registry} do
    user_id = 1

    StoreRegistry.create(registry, user_id)
    {:ok, store} = StoreRegistry.lookup(registry, user_id)
    # synchronous operation -
    # no need to wait till agent process is terminated
    Agent.stop(store)

    ensure_store_removed_from_registry(registry)
    assert StoreRegistry.lookup(registry, user_id) == :error
  end

  test "removes user rate store on crash", %{registry: registry} do
    user_id = 1

    StoreRegistry.create(registry, user_id)
    {:ok, store} = StoreRegistry.lookup(registry, user_id)

    # crash store
    ref = Process.monitor(store)
    # asynchronous operation unlike Agent.stop
    Process.exit(store, :shutdown)

    # wait till agent process is terminated
    assert_receive {:DOWN, ^ref, _, _, _}

    ensure_store_removed_from_registry(registry)
    assert StoreRegistry.lookup(registry, user_id) == :error
  end

  # ensure registry has processed DOWN message and
  # has removed user store after stopping agent
  defp ensure_store_removed_from_registry(registry) do
    fake_user_id = 123
    StoreRegistry.create(registry, fake_user_id)
  end
end
