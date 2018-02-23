defmodule Neko.UserRate do
  @moduledoc false

  alias Neko.UserRate.Store
  alias Neko.UserRate.Store.Registry

  defstruct ~w(
    id
    user_id
    target_id
    target_type
    score
    status
  )a

  def from_request(request) do
    struct(__MODULE__, Map.from_struct(request))
  end

  def load(user_id) do
    case Registry.lookup(user_id) do
      {:ok, _store} -> {:ok, :already_loaded}
      :error -> reload(user_id)
    end
  end

  def reload(user_id) do
    user_id
    |> Registry.fetch()
    |> Store.reload(user_id)
  end

  # stopping user rate store stops underlying agent ->
  # monitoring process (user rate store registry) is notified about
  # about terminated agent process and deletes ETS entry for specified
  # user_id (no user rate store is mapped to that user_id any longer)
  def stop(user_id) do
    case Registry.lookup(user_id) do
      {:ok, store} -> Store.stop(store)
      :error -> {:ok, :not_found}
    end
  end

  def all(user_id) do
    # credo:disable-for-next-line Credo.Check.Refactor.PipeChainStart
    store(user_id) |> Store.all()
  end

  def put(user_id, user_rate) do
    # credo:disable-for-next-line Credo.Check.Refactor.PipeChainStart
    store(user_id) |> Store.put(user_rate)
  end

  def set(user_id, user_rates) do
    # credo:disable-for-next-line Credo.Check.Refactor.PipeChainStart
    store(user_id) |> Store.set(user_rates)
  end

  def delete(user_id, user_rate) do
    # credo:disable-for-next-line Credo.Check.Refactor.PipeChainStart
    store(user_id) |> Store.delete(user_rate)
  end

  defp store(user_id) do
    case Registry.lookup(user_id) do
      {:ok, store} -> store
      :error -> raise "load user_rate store first"
    end
  end
end
