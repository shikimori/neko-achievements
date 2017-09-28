defmodule Neko.Shikimori.Client do
  @adapter Application.get_env(:neko, :shikimori_client)

  @callback get_user_rates!(pos_integer()) :: list(%Neko.UserRate{})
  @callback get_achievements!(pos_integer()) :: list(%Neko.Achievement{})
  @callback get_animes(pos_integer()) :: list(%Neko.Anime{})

  defdelegate get_user_rates!(user_id), to: @adapter
  defdelegate get_achievements!(user_id), to: @adapter
  defdelegate get_animes!(user_id), to: @adapter

  # it's possible to inject shikimori client implementations
  # (adapters) into the modules where client is used -
  # this is just another level of indirection in case you need
  # to prepare data for API call or provide some defaults
end
