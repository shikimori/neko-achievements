defmodule Neko.Achievement.StoreRegistry do
  use GenServer
  alias Neko.Achievement.Store

  # Client API

  def start_link do
    GenServer.start_link(__MODULE__, :ok, [])
  end

  def lookup server, user_id do
    GenServer.call(server, {:lookup, user_id})
  end

  # Server API

  def init(:ok) do
    {:ok, %{}}
  end

  def handle_call {:lookup, user_id}, _from, stores do
    store = stores |> add_store(user_id) |> Map.fetch(user_id)
    {:reply, store, stores}
  end

  defp add_store stores, user_id do
    if Map.has_key?(stores, user_id) do
      stores
    else
      {:ok, store} = Store.start_link
      Map.put(stores, user_id, store)
    end
  end
end
