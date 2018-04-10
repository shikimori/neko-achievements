defmodule Neko.Achievement.StoreTest do
  use ExUnit.Case, async: true

  alias Neko.Achievement
  alias Neko.Achievement.Store

  setup do
    {:ok, pid} = Store.start_link([])
    {:ok, pid: pid}
  end

  test "set achievements", %{pid: pid} do
    achievements =
      MapSet.new([
        %Achievement{neko_id: "foo"},
        %Achievement{neko_id: "bar"}
      ])

    Store.set(pid, achievements)
    assert Store.all(pid) == achievements
  end
end
