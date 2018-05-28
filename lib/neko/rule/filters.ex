defmodule Neko.Rule.Filters do
  def filter_animes(animes, %{filters: nil} = _rule) do
    animes
  end

  def filter_animes(animes, %{filters: filters} = _rule) do
    animes
    |> filter_by_genre_ids(filters["genre_ids"])
    |> filter_by_anime_ids(filters["anime_ids"])
    |> reject_by_anime_ids(filters["not_anime_ids"])
    |> filter_by_year_lte(filters["year_lte"])
    |> filter_by_episodes_gte(filters["episodes_gte"])
    |> filter_by_duration_lte(filters["duration_lte"])
    |> filter_by_franchise(filters["franchise"])
  end

  defp filter_by_genre_ids(animes, nil) do
    animes
  end

  defp filter_by_genre_ids(animes, genre_ids) do
    animes
    |> Enum.reject(&is_nil(&1.genre_ids))
    |> Enum.filter(&lists_overlap?(&1.genre_ids, genre_ids))
  end

  # it's faster than !Enum.empty?(list_1 -- (list_1 -- list_2)),
  # Kernel.!() is a little bit faster than Kernel.not()
  defp lists_overlap?(list_1, list_2) do
    # credo:disable-for-lines:2
    MapSet.new(list_1)
    |> MapSet.intersection(MapSet.new(list_2))
    |> Enum.empty?()
    |> Kernel.!()
  end

  defp filter_by_anime_ids(animes, nil) do
    animes
  end

  defp filter_by_anime_ids(animes, anime_ids) do
    animes
    |> Enum.filter(&Enum.member?(anime_ids, &1.id))
  end

  defp reject_by_anime_ids(animes, nil) do
    animes
  end

  defp reject_by_anime_ids(animes, anime_ids) do
    animes
    |> Enum.reject(&Enum.member?(anime_ids, &1.id))
  end

  defp filter_by_year_lte(animes, nil) do
    animes
  end

  defp filter_by_year_lte(animes, year_lte) do
    animes
    |> Enum.reject(&is_nil(&1.year))
    |> Enum.filter(&(&1.year <= year_lte))
  end

  defp filter_by_episodes_gte(animes, nil) do
    animes
  end

  defp filter_by_episodes_gte(animes, episodes_gte) do
    animes
    |> Enum.reject(&is_nil(&1.episodes))
    |> Enum.filter(&(&1.episodes >= episodes_gte))
  end

  defp filter_by_duration_lte(animes, nil) do
    animes
  end

  defp filter_by_duration_lte(animes, duration_lte) do
    animes
    |> Enum.reject(&is_nil(&1.duration))
    |> Enum.filter(&(&1.duration <= duration_lte))
  end

  defp filter_by_franchise(animes, nil) do
    animes
  end

  defp filter_by_franchise(animes, franchise) do
    animes
    |> Enum.reject(&is_nil(&1.franchise))
    |> Enum.filter(&(&1.franchise == franchise))
  end
end
