defmodule Neko.UserRate.StoreTest do
  use ExUnit.Case, async: true

  alias Neko.UserRate
  alias Neko.UserRate.Store

  setup do
    {:ok, pid} = Store.start_link(%{})
    {:ok, pid: pid}
  end

  test "set user rates", %{pid: pid} do
    user_rate_1 = %UserRate{id: 11}
    user_rate_2 = %UserRate{id: 22}
    user_rates = [user_rate_1, user_rate_2]

    Store.set(pid, user_rates)

    assert Store.all(pid) == %{
             user_rate_1.id => user_rate_1,
             user_rate_2.id => user_rate_2
           }
  end

  test "delete user rate", %{pid: pid} do
    user_rate = %UserRate{id: 999}

    Store.put(pid, user_rate)
    assert Store.all(pid) == %{user_rate.id => user_rate}

    Store.delete(pid, user_rate)
    assert Store.all(pid) == %{}
  end
end
