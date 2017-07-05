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

  # options deteremine what type of keys are
  # attempted to be converted to struct keys
  use ExConstructor,
    atoms: true,
    strings: true,
    camelcase: false,
    uppercamelcase: false,
    underscore: false
end
