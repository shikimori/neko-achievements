defmodule Neko.Shikimori.Client do
  defmodule Behaviour do
    @callback get_user_rates!(pos_integer) :: [Neko.UserRate.t()]
    @callback get_achievements!(pos_integer) :: [Neko.Achievement.t()]
    @callback get_animes!() :: [Neko.Anime.t()]
  end

  @behaviour Behaviour

  @adapter Application.get_env(:neko, :shikimori)[:client]

  @impl true
  defdelegate get_user_rates!(user_id), to: @adapter
  @impl true
  defdelegate get_achievements!(user_id), to: @adapter
  @impl true
  defdelegate get_animes!, to: @adapter
end
