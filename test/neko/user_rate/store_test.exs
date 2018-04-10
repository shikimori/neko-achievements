defmodule Neko.UserRate.StoreTest do
  use ExUnit.Case, async: true

  alias Neko.UserRate
  alias Neko.UserRate.Store

  setup do
    {:ok, pid} = Store.start_link([])
    {:ok, pid: pid}
  end

  test "set user rates", %{pid: pid} do
    user_rates = MapSet.new([%UserRate{id: 1}, %UserRate{id: 2}])

    Store.set(pid, user_rates)
    assert Store.all(pid) == user_rates
  end

  test "delete user rate", %{pid: pid} do
    user_rate = %UserRate{id: 1}

    Store.put(pid, user_rate)
    assert Store.all(pid) == MapSet.new([user_rate])

    Store.delete(pid, user_rate)
    assert Store.all(pid) == MapSet.new()
  end
end
