defmodule Neko.UserRate.Store.RegistryTest do
  use ExUnit.Case, async: true

  alias Neko.UserRate.Store
  alias Neko.UserRate.Store.Registry, as: StoreRegistry

  setup context do
    {:ok, _} = StoreRegistry.start_link(context.test)
    {:ok, registry: context.test}
  end

  test "creates user rate store by user id", %{registry: registry} do
    user_id = 1
    id = 2
    user_rate = %Neko.UserRate{id: id, score: 10}

    assert StoreRegistry.lookup(registry, user_id) == :error

    StoreRegistry.create(registry, user_id)
    assert {:ok, store} = StoreRegistry.lookup(registry, user_id)

    Store.put(store, user_rate.id, user_rate)
    assert Store.get(store, id) == user_rate
  end

  test "removes user rate stores on exit", %{registry: registry} do
    user_id = 1

    store = StoreRegistry.create(registry, user_id)
    Agent.stop(store)

    ensure_store_removed_from_registry(registry)
    assert StoreRegistry.lookup(registry, user_id) == :error
  end

  test "removes user rate store on crash", %{registry: registry} do
    user_id = 1

    store = StoreRegistry.create(registry, user_id)
    ref = Process.monitor(store)
    Process.exit(store, :shutdown)

    assert_receive {:DOWN, ^ref, _, _, _}

    ensure_store_removed_from_registry(registry)
    assert StoreRegistry.lookup(registry, user_id) == :error
  end

  defp ensure_store_removed_from_registry(registry) do
    fake_user_id = 123
    StoreRegistry.create(registry, fake_user_id)
  end
end
