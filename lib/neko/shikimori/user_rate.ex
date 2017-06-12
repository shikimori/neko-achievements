defmodule Neko.Shikimori.UserRate do
  import Neko.Shikimori, only: [make_request!: 3]

  def get_by_user!(user_id) do
    make_request!(:get, "v2/user_rates", %{user_id: user_id})
    |> Poison.decode!(as: [%Neko.UserRate{}])
  end
end
