defmodule Neko.Achievement do
  defstruct ~w(
    user_id
    neko_id
    level
    progress
  )a

  alias Neko.Achievement.Store.Registry

  @shikimori_api Application.get_env(:neko, :shikimori_api)

  def load(user_id) do
    case Registry.lookup(Registry, user_id) do
      {:ok, _store} -> :ok
      :error ->
        Registry.create(Registry, user_id)
        |> Neko.Achievement.Store.set(achievements(user_id))
    end
  end

  defp achievements(user_id) do
    @shikimori_api.get_achievements!(user_id)
  end
end
