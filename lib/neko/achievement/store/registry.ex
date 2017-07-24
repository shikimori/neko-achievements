defmodule Neko.Achievement.Store.Registry do
  @moduledoc """
  Registry of achievements stores:
  each user is mapped to his achievement store.
  """

  use GenServer

  #------------------------------------------------------------------
  # Client API
  #------------------------------------------------------------------

  # different names are specified in tests
  def start_link(name \\ __MODULE__) do
    GenServer.start_link(__MODULE__, name, name: name)
  end

  @doc """
  Fetches achievement store using supplied user_id -
  creates one if it's missing.

  Returns `store`.
  """
  def fetch(server, user_id) do
    GenServer.call(server, {:fetch, user_id})
  end

  @doc """
  Lookups achievement store using supplied `user_id` -
  doesn't try to create one.

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

  def init(name) do
    ets_table = :ets.new(name, [:named_table, read_concurrency: true])
    {:ok, {ets_table, %{}}}
  end

  def handle_call({:fetch, user_id}, _from, state) do
    {store, state} = fetch_store(state, user_id)
    {:reply, store, state}
  end

  # for messages that are not sent via GenServer.call/2 or GenServer.cast/2
  # (includes messages sent via send/2)
  def handle_info({:DOWN, ref, :process, _pid, _reason}, {ets_table, refs}) do
    {user_id, refs} = Map.pop(refs, ref)
    :ets.delete(ets_table, user_id)
    {:noreply, {ets_table, refs}}
  end

  # catch-all clause - discard any unknown messages:
  # there is no such clase for handle_cast/2 or handle_call/2
  # because they deal with messages sent via GenServer API only
  # (unknown message in that case indicates developer mistake)
  def handle_info(_msg, state) do
    {:noreply, state}
  end

  defp fetch_store({ets_table, refs} = state, user_id) do
    case lookup(ets_table, user_id) do
      {:ok, store} -> {store, state}
      :error ->
        # create store and start monitoring it
        {:ok, store} = Neko.Achievement.Store.Supervisor.start_store
        ref = Process.monitor(store)

        :ets.insert(ets_table, {user_id, store})
        {store, {ets_table, Map.put(refs, ref, user_id)}}
    end
  end
end
