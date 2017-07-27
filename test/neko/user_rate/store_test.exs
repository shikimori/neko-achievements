defmodule Neko.UserRate.StoreTest do
  use ExUnit.Case, async: true

  alias Neko.UserRate
  alias Neko.UserRate.Store

  setup do
    {:ok, pid} = Store.start_link
    {:ok, pid: pid}
  end

  test "gets user rate by id", %{pid: pid} do
    id = 1
    user_rate = %UserRate{id: id}

    assert Store.get(pid, id) == nil

    Store.put(pid, user_rate.id, user_rate)
    assert Store.get(pid, id) == user_rate
  end

  test "adds user rates to store using put", %{pid: pid} do
    user_rate_1 = %UserRate{id: 1, score: 8}
    user_rate_2 = %UserRate{id: 2, score: 10}

    Store.put(pid, user_rate_1.id, user_rate_1)
    Store.put(pid, user_rate_2.id, user_rate_2)

    assert Store.all(pid) == [user_rate_1, user_rate_2]
  end

  test "adds user rates to store using set", %{pid: pid} do
    user_rates = [%UserRate{id: 1}, %UserRate{id: 2}]

    Store.set(pid, user_rates)
    assert Store.all(pid) == user_rates
  end

  test "updates user rate", %{pid: pid} do
    user_rate = %UserRate{id: 1, score: 8}

    Store.put(pid, user_rate.id, user_rate)
    Store.update(pid, user_rate.id, %{score: 9})

    assert Store.all(pid) == [%UserRate{id: 1, score: 9}]
  end

  test "deletes user rate by id", %{pid: pid} do
    user_rate = %UserRate{id: 1}

    Store.put(pid, user_rate.id, user_rate)
    assert Store.get(pid, user_rate.id) == user_rate

    Store.delete(pid, user_rate.id)
    assert Store.get(pid, user_rate.id) == nil
  end
end
