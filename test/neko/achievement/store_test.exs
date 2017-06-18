defmodule Neko.Achievement.StoreTest do
  use ExUnit.Case, async: true

  alias Neko.Achievement
  alias Neko.Achievement.Store

  setup do
    {:ok, store} = Store.start_link
    {:ok, store: store}
  end

  test "stores achievement", %{store: store} do
    achievement = %Achievement{neko_id: 1}

    assert Store.all(store) == %MapSet{}

    Store.put(store, achievement)
    assert Store.all(store) == MapSet.new([achievement])

    Store.delete(store, achievement)
    assert Store.all(store) == %MapSet{}
  end
end
