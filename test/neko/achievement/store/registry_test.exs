defmodule Neko.Achievement.Store.RegistryTest do
  use ExUnit.Case, async: true

  alias Neko.Achievement.Store
  alias Neko.Achievement.Store.Registry, as: StoreRegistry

  setup context do
    # context.test - name of specific test
    # (say, 'creates store by user_id')
    {:ok, registry} = StoreRegistry.start_link(context.test)
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
    # synchronous operation
    Agent.stop(store)
    assert StoreRegistry.lookup(registry, user_id) == :error
  end

  @tag :wip
  test "removes store on crash", %{registry: registry} do
    user_id = 1

    StoreRegistry.create(registry, user_id)
    {:ok, store} = StoreRegistry.lookup(registry, user_id)

    # crash store
    ref = Process.monitor(store)
    # asynchronous operation unlike Agent.stop
    Process.exit(store, :shutdown)

    # wait till store is dead
    assert_receive {:DOWN, ^ref, _, _, _}

    assert StoreRegistry.lookup(registry, user_id) == :error
  end
end
