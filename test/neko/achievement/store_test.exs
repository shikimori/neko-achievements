defmodule Neko.Achievement.StoreTest do
  use ExUnit.Case, async: true

  alias Neko.Achievement
  alias Neko.Achievement.Store

  # runs before each test
  setup do
    {:ok, store} = Store.start_link
    {:ok, store: store}
  end

  # pass store to each test using 'test context'
  test "stores achievement by its neko id", %{store: store} do
    neko_id = 1
    achievement = %Achievement{neko_id: neko_id}

    assert Store.get(store, neko_id) == nil

    Store.put(store, neko_id, achievement)
    assert Store.get(store, neko_id) == achievement

    Store.delete(store, neko_id)
    assert Store.get(store, neko_id) == nil
  end
end
