defmodule Neko.Request do
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

  def process(%{user_id: user_id} = request) do
    load_user_data(user_id)
    process_action(request)

    new_achievements = calculate_achievements(user_id)
    diff = calculate_diff(user_id, new_achievements)
    save_new_achievements(user_id, new_achievements)

    diff
  end

  defp load_user_data(user_id) do
    [
      Task.async(fn -> Neko.Achievement.load(user_id) end),
      Task.async(fn -> Neko.UserRate.load(user_id) end)
    ]
    |> Enum.map(&Task.await/1)
  end

  defp process_action(%{action: "noop"}) do
  end
  defp process_action(%{id: id, user_id: user_id, action: "create"} = request) do
    Neko.UserRate.put(user_id, id, Neko.UserRate.from_request(request))
  end
  defp process_action(%{id: id, user_id: user_id, action: "update"} = request) do
    Neko.UserRate.update(user_id, id, Map.from_struct(request))
  end
  defp process_action(%{id: id, user_id: user_id, action: "destroy"}) do
    Neko.UserRate.delete(user_id, id)
  end

  defp calculate_achievements(user_id) do
    user_id
    |> Neko.UserRate.all()
    |> Neko.Achievement.Calculator.call(user_id)
  end

  defp calculate_diff(user_id, new_achievements) do
    user_id
    |> Neko.Achievement.all()
    |> Neko.Achievement.Diff.call(new_achievements)
  end

  defp save_new_achievements(user_id, achievements) do
    Neko.Achievement.set(user_id, achievements)
  end
end
