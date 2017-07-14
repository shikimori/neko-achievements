defmodule Neko.UserRate.StoreTest do
  use ExUnit.Case, async: true

  alias Neko.UserRate
  alias Neko.UserRate.Store

  setup do
    {:ok, store} = Store.start_link
    {:ok, store: store}
  end

  test "gets user rate by id", %{store: store} do
    id = 1
    user_rate = %UserRate{id: id}

    assert Store.get(store, id) == nil

    Store.put(store, user_rate.id, user_rate)
    assert Store.get(store, id) == user_rate
  end

  test "adds user rates to store using put", %{store: store} do
    user_rate_1 = %UserRate{id: 1, score: 8}
    user_rate_2 = %UserRate{id: 2, score: 10}

    Store.put(store, user_rate_1.id, user_rate_1)
    Store.put(store, user_rate_2.id, user_rate_2)

    assert Store.all(store) == [user_rate_1, user_rate_2]
  end

  test "adds user rates to store using set", %{store: store} do
    user_rates = [%UserRate{id: 1}, %UserRate{id: 2}]

    Store.set(store, user_rates)
    assert Store.all(store) == user_rates
  end

  test "deletes user rate by id", %{store: store} do
    id = 1
    user_rate = %UserRate{id: id}

    Store.put(store, user_rate.id, user_rate)
    assert Store.get(store, id) == user_rate

    Store.delete(store, user_rate.id)
    assert Store.get(store, id) == nil
  end
end
