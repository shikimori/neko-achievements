defmodule Neko.Achievement.Calculator do
  def call(request) do
    load_user_data(request.user_id)
  end

  defp load_user_data user_id do
    load_tasks |> Enum.map(&Task.await/1)
  end

  defp load_tasks do
    [Task.async(fn -> Neko.Achievement.load(user_id) end),
     Task.async(fn -> Neko.UserRate.load(user_id) end)]
  end
end
