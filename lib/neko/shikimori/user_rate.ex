defmodule Neko.Shikimori.UserRate do
  # currently structs are created directly by Kernel.struct/2
  #@derive Poison.Decoder
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
