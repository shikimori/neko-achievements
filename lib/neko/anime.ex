defmodule Neko.Anime do
  @moduledoc false

  alias Neko.Anime.Store

  defstruct ~w(
    id
    genre_ids
    year
    episodes
  )a

  @rules_list Application.get_env(:neko, :rules)[:list]

  defdelegate reload, to: Store
  defdelegate all, to: Store

  def set(animes) do
    animes |> Store.set()
    # recalculate anime_ids for all rules
    @rules_list |> Enum.each(&(&1.reload()))
  end
end
