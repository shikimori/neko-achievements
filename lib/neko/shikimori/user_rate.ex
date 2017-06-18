defmodule Neko.Shikimori.UserRate do
  import Neko.Shikimori, only: [make_request!: 3]

  def get_by_user!(user_id) do
    params = %{user_id: user_id, status: :completed}
    make_request!(:get, "v2/user_rates", params)
    |> Poison.decode!(as: [%Neko.UserRate{}])
  end
end
