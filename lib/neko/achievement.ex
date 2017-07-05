# TODO: add spec
defmodule Neko.Achievement do
  defstruct ~w(
    user_id
    neko_id
    level
    progress
  )a

  alias Neko.Achievement.Store
  alias Neko.Achievement.Store.Registry

  def load(user_id) do
    case Registry.lookup(Registry, user_id) do
      {:ok, _store} -> :ok
      :error ->
        Registry.create(Registry, user_id)
        |> Store.set(achievements(user_id))
    end
  end

  defp achievements(user_id) do
    Neko.Shikimori.Achievement.get_by_user!(user_id)
  end
end
