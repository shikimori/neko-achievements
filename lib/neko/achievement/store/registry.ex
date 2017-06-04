defmodule Neko.Achievement.Store.Registry do
  @moduledoc """
  Registry of achievements stores by user id:
  maps one achievement store to one user.
  """

  use GenServer

  alias Neko.Achievement.Store.Supervisor, as: StoreSupervisor

  # Client API

  def start_link name do
    GenServer.start_link(__MODULE__, :ok, name: name)
  end

  def create server, user_id do
    GenServer.cast(server, {:create, user_id})
  end

  def lookup server, user_id do
    GenServer.call(server, {:lookup, user_id})
  end

  # Server API

  def init(:ok) do
    user_ids = %{}
    refs = %{}

    {:ok, {user_ids, refs}}
  end

  def handle_cast {:create, user_id}, state do
    state = add_store(state, user_id)
    {:noreply, state}
  end

  def handle_call {:lookup, user_id}, _from, {user_ids, _} = state do
    store = Map.fetch(user_ids, user_id)
    {:reply, store, state}
  end

  # for messages that are not sent via GenServer.call/2 or GenServer.cast/2
  # (includes messages sent via send/2)
  def handle_info {:DOWN, ref, :process, _pid, _reason}, {user_ids, refs} do
    {user_id, refs} = Map.pop(refs, ref)
    user_ids = Map.delete(user_ids, user_id)
    {:noreply, {user_ids, refs}}
  end

  # catch-all clause - discard any unknown messages:
  # there is no such clase for handle_cast/2 or handle_call/2
  # because they deal with messages sent via GenServer API only
  # (unknown message in that case indicates developer mistake)
  def handle_info _msg, state do
    {:noreply, state}
  end

  defp add_store {user_ids, refs} = state, user_id do
    if Map.has_key?(user_ids, user_id) do
      state
    else
      # create store and start monitoring it
      {:ok, store} = StoreSupervisor.start_store
      ref = Process.monitor(store)

      user_ids = Map.put(user_ids, user_id, store)
      refs = Map.put(refs, ref, user_id)

      {user_ids, refs}
    end
  end
end
