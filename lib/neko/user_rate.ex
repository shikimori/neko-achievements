# TODO: add spec
defmodule Neko.UserRate do
  defstruct ~w(
    id
    user_id
    target_id
    target_type
    score
    status
    rewatches
    episodes
    volumes
    chapters
  )a

  alias Neko.UserRate.Store
  alias Neko.UserRate.Store.Registry

  def load(user_id) do
    case Registry.lookup(Registry, user_id) do
      {:ok, _store} -> :ok
      :error ->
        Registry.create(Registry, user_id)
        |> Store.set(user_rates(user_id))
    end
  end

  defp user_rates(user_id) do
    Neko.Shikimori.UserRate.get_by_user!(user_id)
  end
end
