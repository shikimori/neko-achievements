defmodule Neko.Anime.Store do
  @type anime_t :: %Neko.Anime{}
  @type animes_t :: MapSet.t(anime_t)

  @spec start_link(String.t) :: Agent.on_start
  def start_link(name \\ __MODULE__) do
    Agent.start_link(fn -> animes() end, name: name)
  end

  @spec reload(String.t) :: :ok
  def reload(name \\ __MODULE__) do
    Agent.update(name, fn(_) -> animes() end)
  end

  @spec all(String.t) :: animes_t
  def all(name \\ __MODULE__) do
    Agent.get(name, &(&1))
  end

  @spec set(String.t, animes_t) :: :ok
  def set(name \\ __MODULE__, animes) do
    Agent.update(name, fn(_) -> animes end)
  end

  @spec animes() :: animes_t
  defp animes do
    Neko.Shikimori.Client.get_animes!()
    |> MapSet.new()
  end
end
