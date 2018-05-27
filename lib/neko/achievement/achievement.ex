defmodule Neko.Achievement do
  @moduledoc false

  # > For maximum performance, make sure you
  # > @derive [Poison.Encoder] for any struct
  # > you plan on encoding.
  @derive [Poison.Encoder]

  alias Neko.Achievement.Store
  alias Neko.Achievement.Store.Registry

  defstruct ~w(
    user_id
    neko_id
    level
    progress
  )a

  @type t :: %__MODULE__{}

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

  def set(user_id, achievements) do
    # credo:disable-for-next-line Credo.Check.Refactor.PipeChainStart
    store(user_id) |> Store.set(achievements)
  end

  defp store(user_id) do
    case Registry.lookup(user_id) do
      {:ok, store} ->
        store

      # it's not loaded or it crashed in previous request and :DOWN message
      # was received only after loading user rates in current request
      :error ->
        raise "achievement store is not found in registry"
    end
  end
end
