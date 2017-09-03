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

  def from_request(request) do
    struct(__MODULE__, Map.from_struct(request))
  end

  def load(user_id) do
    case Registry.lookup(user_id) do
      {:ok, _store} -> :ok
      :error ->
        Registry.fetch(user_id)
        |> Neko.UserRate.Store.set(user_rates(user_id))
    end
  end

  def all(user_id) do
    store(user_id) |> Neko.UserRate.Store.all()
  end

  def put(user_id, id, user_rate) do
    store(user_id) |> Neko.UserRate.Store.put(id, user_rate)
  end

  def update(user_id, id, map) do
    store(user_id) |> Neko.UserRate.Store.update(id, map)
  end

  def delete(user_id, id) do
    store(user_id) |> Neko.UserRate.Store.delete(id)
  end

  defp store(user_id) do
    Registry.fetch(user_id)
  end

  defp user_rates(user_id) do
    Neko.Shikimori.Client.get_user_rates!(user_id)
  end
end
