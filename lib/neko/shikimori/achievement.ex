defmodule Neko.Shikimori.Achievement do
  import Neko.Shikimori, only: [make_request!: 3]

  def get_by_user!(user_id) do
    make_request!(:get, "achievements", %{user_id: user_id})
    |> Poison.decode!(as: [%Neko.Achievement{}])
  end
end
