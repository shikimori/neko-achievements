defmodule Neko.Rules.Rule do
  @moduledoc false

  # can't specify all callback modules as union type - this would
  # result in 'deadlocked waiting on module Neko.Rules.SimpleRule'
  # (-> Rule and SimpleRule wait for each other to be compiled)
  @typep rule_t :: struct

  @callback set([rule_t]) :: any
  @callback achievements([rule_t], pos_integer) :: [%Neko.Achievement{}]
  @callback reload() :: any
end
