defmodule Neko.UserRate.Store.Registry do
  @moduledoc """
  Registry of user rate stores:
  each user is mapped to his user rate store.
  """

  use GenServer

  #------------------------------------------------------------------
  # Client API
  #------------------------------------------------------------------

  def start_link(name \\ __MODULE__) do
    GenServer.start_link(__MODULE__, name, name: name)
  end

  @doc """
  Fetches achievement store using supplied user_id -
  creates one if it's missing.

  Returns `store`.
  """
  def fetch(name \\ __MODULE__, user_id) do
    GenServer.call(name, {:fetch, user_id})
  end

  @doc """
  Lookups user rate store using supplied `user_id` -
  doesn't try to create one.

  Returns `{:ok, store_pid}` if store exists, `:error` otherwise.
  """
  def lookup(name \\ __MODULE__, user_id) do
    case :ets.lookup(name, user_id) do
      [{^user_id, store_pid}] -> {:ok, store_pid}
      [] -> :error
    end
  end

  @doc """
  Stops the registry.
  """
  def stop(name \\ __MODULE__) do
    GenServer.stop(name)
  end

  #------------------------------------------------------------------
  # Server API
  #------------------------------------------------------------------

  def init(name) do
    ets_table = :ets.new(name, [:named_table, read_concurrency: true])
    {:ok, {ets_table, %{}}}
  end

  def handle_call({:fetch, user_id}, _from, state) do
    {store_pid, state} = fetch_store(state, user_id)
    {:reply, store_pid, state}
  end

  def handle_info({:DOWN, ref, :process, _pid, _reason}, {ets_table, refs}) do
    {user_id, refs} = Map.pop(refs, ref)
    :ets.delete(ets_table, user_id)
    {:noreply, {ets_table, refs}}
  end

  def handle_info(_msg, state) do
    {:noreply, state}
  end

  defp fetch_store({ets_table, refs} = state, user_id) do
    case lookup(ets_table, user_id) do
      {:ok, store_pid} -> {store_pid, state}
      :error ->
        {:ok, store_pid} = Neko.UserRate.Store.Supervisor.start_store()
        ref = Process.monitor(store_pid)

        :ets.insert(ets_table, {user_id, store_pid})
        {store_pid, {ets_table, Map.put(refs, ref, user_id)}}
    end
  end
end
