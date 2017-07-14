defmodule Neko.UserRate.Store.Registry do
  @moduledoc """
  Registry of user rate stores:
  each user is mapped to his user rate store.
  """

  use GenServer

  #------------------------------------------------------------------
  # Client API
  #------------------------------------------------------------------

  def start_link(name) do
    GenServer.start_link(__MODULE__, name, name: name)
  end

  def create(server, user_id) do
    GenServer.call(server, {:create, user_id})
  end

  @doc """
  Lookups user rate store using supplied `user_id`.

  Returns `{:ok, store}` if store exists, `:error` otherwise.
  """
  def lookup(server, user_id) do
    case :ets.lookup(server, user_id) do
      [{^user_id, store}] -> {:ok, store}
      [] -> :error
    end
  end

  @doc """
  Stops the registry.
  """
  def stop(server) do
    GenServer.stop(server)
  end

  #------------------------------------------------------------------
  # Server API
  #------------------------------------------------------------------

  def init(table) do
    user_ids = :ets.new(table, [:named_table, read_concurrency: true])
    refs = %{}

    {:ok, {user_ids, refs}}
  end

  def handle_call({:create, user_id}, _from, state) do
    {store, state} = add_store(state, user_id)
    {:reply, store, state}
  end

  # for messages that are not sent via GenServer.call/2 or GenServer.cast/2
  # (includes messages sent via send/2)
  def handle_info({:DOWN, ref, :process, _pid, _reason}, {user_ids, refs}) do
    {user_id, refs} = Map.pop(refs, ref)
    :ets.delete(user_ids, user_id)
    {:noreply, {user_ids, refs}}
  end

  # catch-all clause - discard any unknown messages:
  # there is no such clase for handle_cast/2 or handle_call/2
  # because they deal with messages sent via GenServer API only
  # (unknown message in that case indicates developer mistake)
  def handle_info(_msg, state) do
    {:noreply, state}
  end

  defp add_store({user_ids, refs} = state, user_id) do
    case lookup(user_ids, user_id) do
      {:ok, store} -> {store, state}
      :error ->
        # create store and start monitoring it
        {:ok, store} = Neko.UserRate.Store.Supervisor.start_store
        ref = Process.monitor(store)

        :ets.insert(user_ids, {user_id, store})
        refs = Map.put(refs, ref, user_id)

        {store, {user_ids, refs}}
    end
  end
end
