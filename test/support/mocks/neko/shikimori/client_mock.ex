defmodule Neko.Shikimori.ClientMock do
  @behaviour Neko.Shikimori.Client.Behaviour

  @impl true
  def get_user_rates!(_user_id), do: []
  @impl true
  def get_achievements!(_user_id), do: []
  @impl true
  def get_animes!, do: []
end
