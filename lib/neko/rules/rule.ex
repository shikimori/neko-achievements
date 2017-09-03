defmodule Neko.Rules.Rule do
  @callback achievements([%Neko.UserRate{}], pos_integer()) :: [%Neko.Achievement{}]
end
