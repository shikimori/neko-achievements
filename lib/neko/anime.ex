defmodule Neko.Anime do
  alias Neko.Anime.Store

  defstruct ~w(
    id
    genre_ids
  )a

  def all do
    Store.all()
  end

  def set(animes) do
    Store.set(animes)
    # TODO: reload all rules using their reload method
    # TODO: get all rules from config
    # TODO: move all load functions from UserRate, Achievement and
    #       Anime to corresponding stores?
    #       think of load() vs. reload()
  end
end
