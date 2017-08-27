defmodule Neko.Achievement.Calculator do
  @adapter Application.get_env(:neko, :calculator)
  @callback call(pos_integer()) :: [%Neko.Achievement{}]

  defdelegate call(user_id), to: @adapter
end
