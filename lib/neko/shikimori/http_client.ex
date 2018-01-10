# http://blog.plataformatec.com.br/2015/10/mocks-and-explicit-contracts/
#
# credo:disable-for-this-file Credo.Check.Refactor.PipeChainStart
defmodule Neko.Shikimori.HTTPClient do
  @moduledoc false

  @behaviour Neko.Shikimori.Client.Behaviour

  use HTTPoison.Base

  @base_url Application.get_env(:neko, :shikimori)[:url]
  @recv_timeout Application.get_env(:neko, :shikimori)[:recv_timeout]

  def get_user_rates!(user_id) do
    params = %{user_id: user_id, status: :completed}
    json = make_request!(:get, "v2/user_rates", params)

    json
    |> Poison.decode(as: [%Neko.UserRate{}])
    |> handle_parse_json(json)
  end

  def get_achievements!(user_id) do
    params = %{user_id: user_id}
    json = make_request!(:get, "achievements", params)

    json
    |> Poison.decode!(as: [%Neko.Achievement{}])
    |> handle_parse_json(json)
  end

  def get_animes! do
    json = make_request!(:get, "animes/neko")

    json
    |> Poison.decode!(as: [%Neko.Anime{}])
    |> handle_parse_json(json)
  end

  defp make_request!(:get, path, params \\ %{}) do
    get!(path, [], params: params).body
  end

  defp handle_parse_json(result, json) do
    case result do
      {:ok, value} -> value
      {:error, _} -> raise("error parsing shikimori response: #{json}")
    end
  end

  defp process_request_options(options) do
    Keyword.merge(options, recv_timeout: @recv_timeout)
  end

  defp process_url("/" <> path), do: process_url(path)
  defp process_url(path), do: @base_url <> path
end
