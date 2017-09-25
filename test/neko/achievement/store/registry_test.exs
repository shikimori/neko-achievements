defmodule Neko.Achievement.Store.RegistryTest do
  use ExUnit.Case, async: true

  alias Neko.Achievement.Store
  alias Neko.Achievement.Store.Registry, as: StoreRegistry

  setup context do
    # context.test - name of specific test
    # (say, :"fetches store by user_id")
    {:ok, _} = StoreRegistry.start_link(context.test)
    # use registry by its name, not pid
    {:ok, name: context.test}
  end

  # NOTE: make sure test descriptions are unique across all tests since they
  #       are used as registry names - otherwise you'll get this error when
  #       trying to start registry with the same name in another test file:
  #
  #       no match of right hand side value: {:error, {:already_started, ...}}
  test "fetches achievement store by user id", %{name: name} do
    user_id = 1
    achievement = %Neko.Achievement{neko_id: "foo", level: 3}

    assert StoreRegistry.lookup(name, user_id) == :error

    StoreRegistry.fetch(name, user_id)
    assert {:ok, store_pid} = StoreRegistry.lookup(name, user_id)

    Store.put(store_pid, achievement)
    assert Store.all(store_pid) == MapSet.new([achievement])
  end

  test "removes achievement stores on exit", %{name: name} do
    user_id = 1

    store_pid = StoreRegistry.fetch(name, user_id)
    # synchronous operation -
    # no need to wait till agent process is terminated
    Agent.stop(store_pid)

    ensure_store_removed_from_registry(name)
    assert StoreRegistry.lookup(name, user_id) == :error
  end

  test "removes achievement store on crash", %{name: name} do
    user_id = 1

    store_pid = StoreRegistry.fetch(name, user_id)
    # crash store
    ref = Process.monitor(store_pid)
    # asynchronous operation unlike Agent.stop
    Process.exit(store_pid, :shutdown)

    # wait till agent process is terminated
    assert_receive {:DOWN, ^ref, _, _, _}

    ensure_store_removed_from_registry(name)
    assert StoreRegistry.lookup(name, user_id) == :error
  end

  # ensure registry has processed DOWN message and
  # has removed user store after stopping agent
  defp ensure_store_removed_from_registry(name) do
    fake_user_id = 123
    StoreRegistry.fetch(name, fake_user_id)
  end
end
