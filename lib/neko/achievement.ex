defmodule Neko.Achievement do
  # "For maximum performance, make sure you
  # @derive [Poison.Encoder] for any struct you plan on encoding."
  @derive [Poison.Encoder]

  alias Neko.Achievement.Store
  alias Neko.Achievement.Store.Registry

  defstruct ~w(
    user_id
    neko_id
    level
    progress
  )a

  def load(user_id) do
    case Registry.lookup(user_id) do
      {:ok, _store} -> {:ok, :already_loaded}
      :error -> Store.reload(user_id)
    end
  end

  def all(user_id) do
    store(user_id) |> Store.all()
  end

  def set(user_id, achievements) do
    store(user_id) |> Store.set(achievements)
  end

  defp store(user_id) do
    case Registry.lookup(user_id) do
      {:ok, store} -> store
      :error -> raise("load achievement store first")
    end
  end
end
