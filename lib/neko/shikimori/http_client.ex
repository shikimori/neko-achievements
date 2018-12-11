# http://blog.plataformatec.com.br/2015/10/mocks-and-explicit-contracts/
#
# credo:disable-for-this-file Credo.Check.Refactor.PipeChainStart
defmodule Neko.Shikimori.HTTPClient do
  @behaviour Neko.Shikimori.Client.Behaviour

  use HTTPoison.Base

  @base_url Application.get_env(:neko, :shikimori)[:url]
  @conn_timeout Application.get_env(:neko, :shikimori)[:conn_timeout]
  @recv_timeout Application.get_env(:neko, :shikimori)[:recv_timeout]
  @pool_name Application.get_env(:neko, :shikimori)[:pool][:name]

  @impl true
  def get_user_rates!(user_id) do
    params = %{
      user_id: user_id,
      status: "completed,rewatching",
      target_type: "Anime"
    }

    json = make_request!(:get, "v2/user_rates", params)

    json
    |> Poison.decode(as: [%Neko.UserRate{}])
    |> handle_parse_json!(json)
  end

  @impl true
  def get_achievements!(user_id) do
    params = %{user_id: user_id}
    json = make_request!(:get, "achievements", params)

    json
    |> Poison.decode(as: [%Neko.Achievement{}])
    |> handle_parse_json!(json)
  end

  @impl true
  def get_animes! do
    json = make_request!(:get, "animes/neko")

    json
    |> Poison.decode(as: [%Neko.Anime{}])
    |> handle_parse_json!(json)
  end

  # https://hexdocs.pm/httpoison/HTTPoison.html#request/5
  #
  # add static request options here,
  # dynamic ones - in make_request!/2
  @impl true
  def process_request_options(options) do
    Keyword.merge(
      options,
      timeout: @conn_timeout,
      recv_timeout: @recv_timeout,
      ssl: [versions: [:"tlsv1.2"]],
      hackney: [pool: @pool_name, reuseaddr: false]
    )
  end

  @impl true
  def process_url("/" <> path), do: process_url(path)
  @impl true
  def process_url(path), do: @base_url <> path

  defp make_request!(:get, path, params \\ %{}) do
    get!(path, [], params: params).body
  end

  defp handle_parse_json!(result, json) do
    case result do
      {:ok, value} -> value
      {:error, _} -> raise "error parsing shikimori response: #{json}"
    end
  end
end
