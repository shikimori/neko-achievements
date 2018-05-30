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
end
