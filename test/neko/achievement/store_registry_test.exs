defmodule Neko.Achievement.StoreRegistryTest do
  use ExUnit.Case, async: true

  alias Neko.Achievement.Store
  alias Neko.Achievement.StoreRegistry

  setup do
    {:ok, registry} = StoreRegistry.start_link
    {:ok, registry: registry}
  end

  test "creates store by user_id", %{registry: registry} do
    user_id = 1
    achievement_id = 2
    achievement = %{neko_id: 2, level: 2, progress: 20}

    StoreRegistry.create(registry, user_id)
    assert {:ok, store} = StoreRegistry.lookup(registry, user_id)

    Store.put(store, achievement_id, achievement)
    assert Store.get(store, achievement_id) == achievement
  end

  test "removes stores on exit", %{registry: registry} do
    user_id = 1

    StoreRegistry.create(registry, user_id)
    {:ok, store} = StoreRegistry.lookup(registry, user_id)
    Agent.stop(store)
    assert StoreRegistry.lookup(registry, user_id) == :error
  end
end
