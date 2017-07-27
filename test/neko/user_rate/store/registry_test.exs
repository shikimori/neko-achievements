defmodule Neko.UserRate.Store.RegistryTest do
  use ExUnit.Case, async: true

  alias Neko.UserRate.Store
  alias Neko.UserRate.Store.Registry, as: StoreRegistry

  setup context do
    {:ok, _} = StoreRegistry.start_link(context.test)
    {:ok, name: context.test}
  end

  test "fetches user rate store by user id", %{name: name} do
    user_id = 1
    id = 2
    user_rate = %Neko.UserRate{id: id, score: 10}

    assert StoreRegistry.lookup(name, user_id) == :error

    StoreRegistry.fetch(name, user_id)
    assert {:ok, store_pid} = StoreRegistry.lookup(name, user_id)

    Store.put(store_pid, user_rate.id, user_rate)
    assert Store.get(store_pid, id) == user_rate
  end

  test "removes user rate stores on exit", %{name: name} do
    user_id = 1

    store_pid = StoreRegistry.fetch(name, user_id)
    Agent.stop(store_pid)

    ensure_store_removed_from_registry(name)
    assert StoreRegistry.lookup(name, user_id) == :error
  end

  test "removes user rate store on crash", %{name: name} do
    user_id = 1

    store_pid = StoreRegistry.fetch(name, user_id)
    ref = Process.monitor(store_pid)
    Process.exit(store_pid, :shutdown)

    assert_receive {:DOWN, ^ref, _, _, _}

    ensure_store_removed_from_registry(name)
    assert StoreRegistry.lookup(name, user_id) == :error
  end

  defp ensure_store_removed_from_registry(name) do
    fake_user_id = 123
    StoreRegistry.fetch(name, fake_user_id)
  end
end
