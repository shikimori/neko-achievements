defmodule Neko.Anime do
  defstruct ~w(
    id
    genre_ids
  )a

  def all do
    Neko.Anime.Store.all()
  end
end
