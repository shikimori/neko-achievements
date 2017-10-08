defmodule Neko.Shikimori.MockClient do
  @behaviour Neko.Shikimori.Client

  def get_user_rates!(_user_id), do: []
  def get_achievements!(_user_id), do: []
  def get_animes!, do: []
end
