defmodule Neko.Anime.Store do
  def start_link(name \\ __MODULE__) do
    Agent.start_link(fn -> animes() end, name: name)
  end

  def reload(name \\ __MODULE__) do
    Agent.update(name, fn _ -> animes() end)
  end

  def all(name \\ __MODULE__) do
    Agent.get(name, &(&1))
  end

  def set(name \\ __MODULE__, animes) do
    Agent.update(name, fn _ -> animes end)
  end

  defp animes do
    Neko.Shikimori.Client.get_animes!()
  end
end
