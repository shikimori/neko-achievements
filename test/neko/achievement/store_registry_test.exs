defmodule Neko.Achievement.StoreRegistryTest do
  use ExUnit.Case, async: true

  alias Neko.Achievement.Store
  alias Neko.Achievement.StoreRegistry

  setup do
    {:ok, registry} = StoreRegistry.start_link
    {:ok, registry: registry}
  end

  test "lookups store by user_id", %{registry: registry} do
    user_id = 1
    achievement_id = 2
    achievement = %{neko_id: 2, level: 2, progress: 20}

    assert {:ok, store} = StoreRegistry.lookup(registry, user_id)

    Store.put(store, achievement_id, achievement)
    assert Store.get(store, achievement_id) == achievement
  end
end
