defmodule Neko.Achievement.Store.RegistryTest do
  use ExUnit.Case, async: true

  alias Neko.Achievement
  alias Neko.Achievement.Store
  alias Neko.Achievement.Store.Registry, as: StoreRegistry

  setup context do
    {:ok, _} = StoreRegistry.start_link(context.test)
    {:ok, registry: context.test}
  end

  test "creates achievement store by user id", %{registry: registry} do
    user_id = 1
    achievement = %Achievement{neko_id: 2, level: 3}

    StoreRegistry.create(registry, user_id)
    assert {:ok, store} = StoreRegistry.lookup(registry, user_id)

    Store.put(store, achievement)
    assert Store.all(store) == MapSet.new([achievement])
  end

  test "removes achievement stores on exit", %{registry: registry} do
    user_id = 1

    StoreRegistry.create(registry, user_id)
    {:ok, store} = StoreRegistry.lookup(registry, user_id)
    Agent.stop(store)

    ensure_store_removed_from_registry(registry)
    assert StoreRegistry.lookup(registry, user_id) == :error
  end

  test "removes achievement store on crash", %{registry: registry} do
    user_id = 1

    StoreRegistry.create(registry, user_id)
    {:ok, store} = StoreRegistry.lookup(registry, user_id)

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
