defmodule Neko.Rules.Rule do
  @moduledoc false

  defstruct ~w(
    neko_id
    level
    threshold
    filters
    next_threshold
    anime_ids
    duration
  )a

  use ExConstructor, atoms: true, strings: true

  @type t :: %__MODULE__{}

  @callback set([t]) :: any
  @callback achievements([t], pos_integer) :: [%Neko.Achievement{}]
  @callback reload() :: any
end
