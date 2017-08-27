defmodule Neko.Achievement.Calculator.Mock do
  @behaviour Neko.Achievement.Calculator

  def call(user_id) do
    [
      %Neko.Achievement{user_id: user_id, neko_id: 1, level: 1, progress: 100},
      %Neko.Achievement{user_id: user_id, neko_id: 1, level: 2, progress: 40}
    ]
    |> MapSet.new()
  end
end
