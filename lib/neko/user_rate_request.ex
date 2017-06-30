defmodule Neko.UserRateRequest do
  defstruct ~w(
    id
    user_id
    target_id
    score
    status
    episodes
    action
  )a
end
