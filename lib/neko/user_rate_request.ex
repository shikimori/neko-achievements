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

  # only atoms and strings are allowed as keys,
  # string keys are converted to atom keys
  use ExConstructor,
    atoms: true,
    strings: true,
    camelcase: false,
    uppercamelcase: false,
    underscore: false
end
