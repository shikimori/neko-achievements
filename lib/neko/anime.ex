defmodule Neko.Anime do
  alias Neko.Anime.Store

  @rules_list Application.get_env(:neko, :rules)[:list]

  defstruct ~w(
    id
    genre_ids
    year
    episodes
  )a

  defdelegate reload, to: Store
  defdelegate all, to: Store

  def set(animes) do
    animes |> Store.set()
    # recalculate anime_ids for all rules
    @rules_list |> Enum.each(&(&1.reload()))
  end
end
