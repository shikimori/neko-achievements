defmodule Neko.Achievement.StoreTest do
  use ExUnit.Case, async: true
  alias Neko.Achievement.Store

  # runs before each test
  setup do
    {:ok, store} = Store.start_link
    {:ok, store: store}
  end

  # pass store to each test using 'test context'
  test "stores achievement by its id", %{store: store} do
    achievement_id = 1
    achievement = %{neko_id: 2, level: 2, progress: 20}

    assert Store.get(store, achievement_id) == nil

    Store.put(store, achievement_id, achievement)
    assert Store.get(store, achievement_id) == achievement

    Store.delete(store, achievement_id)
    assert Store.get(store, achievement_id) == nil
  end
end
