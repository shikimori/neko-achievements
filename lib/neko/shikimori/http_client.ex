# http://blog.plataformatec.com.br/2015/10/mocks-and-explicit-contracts/
defmodule Neko.Shikimori.HTTPClient do
  use HTTPoison.Base

  @base_url "https://shikimori.org/api/"

  def get_user_rates!(user_id) do
    params = %{user_id: user_id, status: :completed}

    make_request!(:get, "v2/user_rates", params)
    |> Poison.decode!(as: [%Neko.UserRate{}])
  end

  def get_achievements!(user_id) do
    make_request!(:get, "achievements", %{user_id: user_id})
    |> Poison.decode!(as: [%Neko.Achievement{}])
  end

  defp make_request!(:get, path, params \\ %{}) do
    get!(path, [], params: params).body
  end

  defp process_url("/" <> path), do: process_url(path)
  defp process_url(path), do: @base_url <> path
end
