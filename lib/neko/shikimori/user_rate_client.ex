require IEx

defmodule Shikimori.UserRateClient do
  use HTTPoison.Base
  alias Shikimori.UserRate

  @base_url "https://shikimori.org/api/v2/"

  defp process_url(url), do: @base_url <> url

  defp process_response_body(body) do
    body
    |> Poison.Parser.parse!(keys: :atoms)
    |> Enum.map(&(struct(UserRate, &1)))
  end
end
