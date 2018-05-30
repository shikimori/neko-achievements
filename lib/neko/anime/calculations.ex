defmodule Neko.Anime.Calculations do
  @moduledoc """
  calc_* functions fill anime fields with calculated values
  """

  @typep anime_t :: Neko.Anime.t()
  @typep animes_t :: MapSet.t(anime_t)

  @spec calc_total_durations(animes_t) :: anime_t
  def calc_total_durations(animes) do
    animes
    |> Enum.map(&%{&1 | total_duration: &1.episodes * &1.duration})
    |> MapSet.new()
  end

  @spec common_duration(animes_t, animes_t) :: pos_integer
  def common_duration(animes_1, animes_2) do
    animes_1
    |> MapSet.intersection(animes_2)
    |> Enum.map(& &1.total_duration)
    |> Enum.sum()
  end
end
