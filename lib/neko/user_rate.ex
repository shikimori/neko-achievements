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

  alias Neko.UserRate.Store.Registry

  @shikimori_api Application.get_env(:neko, :shikimori_api)

  def from_request(request) do
    struct(Neko.UserRate, Map.from_struct(request))
  end

  def load(user_id) do
    case Registry.lookup(Registry, user_id) do
      {:ok, _store} -> :ok
      :error ->
        Registry.create(Registry, user_id)
        |> Neko.UserRate.Store.set(user_rates(user_id))
    end
  end

  defp user_rates(user_id) do
    @shikimori_api.get_user_rates!(user_id)
  end
end
