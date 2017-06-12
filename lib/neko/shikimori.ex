defmodule Neko.Shikimori do
  use HTTPoison.Base

  @base_url "https://shikimori.org/api/"

  def make_request!(:get, path, params \\ %{}) do
    get!(path, [], params: params).body
  end

  defp process_url("/" <> path), do: process_url(path)
  defp process_url(path), do: @base_url <> path
end
