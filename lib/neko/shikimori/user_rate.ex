defmodule Shikimori.UserRate do
  @derive Poison.Decoder
  defstruct ~w(
    id
    user_id
    target_id
    target_type
    score
    status
    rewatches
    episodes
    volumes
    chapters
  )a
end
