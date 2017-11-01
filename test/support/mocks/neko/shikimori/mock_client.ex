defmodule Neko.Shikimori.MockClient do
  @behaviour Neko.Shikimori.Client.Behaviour

  def get_user_rates!(_user_id), do: []
  def get_achievements!(_user_id), do: []
  def get_animes!, do: []
end
