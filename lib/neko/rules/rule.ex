defmodule Neko.Rules.Rule do
  @callback achievements(integer) :: [%Neko.Achievement{}]
end
