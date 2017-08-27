defmodule Neko.Achievement.StoreTest do
  use ExUnit.Case, async: true

  alias Neko.Achievement
  alias Neko.Achievement.Store

  # runs before each test
  setup do
    {:ok, pid} = Store.start_link
    {:ok, pid: pid}
  end

  # pass store pid to each test using test context
  test "adds achievements to store using put", %{pid: pid} do
    achievement_1 = %Achievement{neko_id: 1}
    achievement_2 = %Achievement{neko_id: 2}

    Store.put(pid, achievement_1)
    Store.put(pid, achievement_2)

    assert Store.all(pid) == MapSet.new(
      [achievement_1, achievement_2]
    )
  end

  test "adds achievements to store using set", %{pid: pid} do
    achievements = [%Achievement{neko_id: 1}, %Achievement{neko_id: 2}]

    Store.set(pid, achievements)
    assert Store.all(pid) == MapSet.new(achievements)
  end

  test "deletes achievement from store", %{pid: pid} do
    achievement_1 = %Achievement{neko_id: 1}
    achievement_2 = %Achievement{neko_id: 2}

    Store.put(pid, achievement_1)
    Store.put(pid, achievement_2)

    Store.delete(pid, achievement_1)
    assert Store.all(pid) == MapSet.new([achievement_2])

    Store.delete(pid, achievement_2)
    assert Store.all(pid) == MapSet.new()
  end
end
