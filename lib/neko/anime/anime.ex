defmodule Neko.Anime do
  @moduledoc false

  alias Neko.Anime.Store

  defstruct ~w(
    id
    genre_ids
    year
    episodes
    duration
    franchise
  )a

  @type t :: %__MODULE__{}

  defdelegate reload, to: Store
  defdelegate all, to: Store

  def set(animes) do
    animes |> Store.set()

    # recalculate anime_ids for all rules
    Application.get_env(:neko, :rules)[:module_list]
    |> Enum.each(& &1.reload())
  end
end
