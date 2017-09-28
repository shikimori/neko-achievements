defmodule Neko.Anime.Store do
  def start_link(name \\ __MODULE__) do
    Agent.start_link(fn -> load() end, name: name)
  end

  def all(name \\ __MODULE__) do
    Agent.get(name, &(&1))
  end

  def load do
    Neko.Shikimori.Client.get_animes!()
    |> Enum.reduce(%{}, fn(x, acc) -> Map.put(acc, x.id, x) end)
  end
end
