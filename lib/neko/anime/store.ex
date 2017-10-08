defmodule Neko.Anime.Store do
  def start_link(name \\ __MODULE__) do
    Agent.start_link(fn -> load() end, name: name)
  end

  def all(name \\ __MODULE__) do
    Agent.get(name, &(&1))
  end

  def set(name \\ __MODULE__, animes) do
    Agent.update(name, fn _ -> MapSet.new(animes) end)
  end

  defp load do
    Neko.Shikimori.Client.get_animes!()
  end
end
