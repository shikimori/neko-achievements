defmodule Neko.Anime do
  alias Neko.Anime.Store

  defstruct ~w(
    id
    genre_ids
    genre_v2_ids
    year
    episodes
    duration
    franchise
    total_duration
  )a

  @type t :: %__MODULE__{}

  defdelegate reload, to: Store
  defdelegate all, to: Store
  defdelegate all_by_id, to: Store

  def set(animes) do
    animes |> Store.set()

    # recalculate animes for all rules
    Application.get_env(:neko, :rules)[:module_list]
    |> Enum.each(& &1.reload())
  end
end
