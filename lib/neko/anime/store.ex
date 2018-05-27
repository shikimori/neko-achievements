defmodule Neko.Anime.Store do
  @moduledoc false

  use Agent

  @type anime_t :: Neko.Anime.t()
  @type animes_t :: MapSet.t(anime_t)

  @name __MODULE__

  @spec start_link(any) :: Agent.on_start()
  def start_link(_) do
    Agent.start_link(fn -> animes() end, name: @name)
  end

  @spec reload() :: :ok
  def reload do
    Agent.update(@name, fn _ -> animes() end)
  end

  @spec all() :: animes_t
  def all do
    Agent.get(@name, & &1)
  end

  @spec set([anime_t]) :: :ok
  def set(animes) when is_list(animes) do
    animes |> MapSet.new() |> set()
  end

  @spec set(animes_t) :: :ok
  def set(animes) do
    Agent.update(@name, fn _ -> animes end)
  end

  @spec animes() :: animes_t
  defp animes do
    Neko.Shikimori.Client.get_animes!()
    |> MapSet.new()
  end
end
