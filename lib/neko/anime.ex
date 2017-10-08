defmodule Neko.Anime do
  alias Neko.Anime.Store

  @rules_list Application.get_env(:neko, :rules)[:list]

  defstruct ~w(
    id
    genre_ids
  )a

  defdelegate all, to: Store

  def set(animes) do
    Store.set(animes)
    # recalculate anime_ids for all rules
    @rules_list |> Enum.each(&(&1.reload()))
  end
end
