defmodule Neko.Achievement.StoreTest do
  use ExUnit.Case, async: true

  alias Neko.Achievement
  alias Neko.Achievement.Store

  # runs before each test
  setup do
    {:ok, store} = Store.start_link
    {:ok, store: store}
  end

  # pass store to each test using test context
  test "adds achievements to store using put", %{store: store} do
    achievement_1 = %Achievement{neko_id: 1}
    achievement_2 = %Achievement{neko_id: 2}

    Store.put(store, achievement_1)
    Store.put(store, achievement_2)

    assert Store.all(store) == MapSet.new(
      [achievement_1, achievement_2]
    )
  end

  test "adds achievements to store using set", %{store: store} do
    achievements = [%Achievement{neko_id: 1}, %Achievement{neko_id: 2}]

    Store.set(store, achievements)
    assert Store.all(store) == MapSet.new(achievements)
  end

  test "deletes achievement from store", %{store: store} do
    achievement_1 = %Achievement{neko_id: 1}
    achievement_2 = %Achievement{neko_id: 2}

    Store.put(store, achievement_1)
    Store.put(store, achievement_2)

    Store.delete(store, achievement_1)
    assert Store.all(store) == MapSet.new([achievement_2])

    Store.delete(store, achievement_2)
    assert Store.all(store) == %MapSet{}
  end
end
