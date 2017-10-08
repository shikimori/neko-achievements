defmodule Neko.Request do
  defstruct ~w(
    id
    user_id
    target_id
    score
    status
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
    preprocess_action(request)
    load_user_data(user_id)
    process_action(request)

    new_achievements = calculate_achievements(user_id)
    diff = calculate_diff(user_id, new_achievements)
    save_new_achievements(user_id, new_achievements)

    diff
  end

  defp preprocess_action(%{user_id: user_id, action: "reset"}) do
    Neko.UserRate.reset(user_id)
  end
  defp preprocess_action(%{action: _action}) do
    # nothing to do for other actions
  end

  defp load_user_data(user_id) do
    [Neko.Achievement, Neko.UserRate]
    |> Enum.map(&Task.async(fn -> apply(&1, :load, [user_id]) end))
    |> Enum.map(&Task.await/1)
  end

  defp process_action(%{action: "noop"}) do
  end
  defp process_action(%{action: "reset"}) do
    # user rates are reset in preprocess_action
    # and loaded in process_action
  end
  defp process_action(%{id: id, user_id: user_id, action: "put"} = request) do
    Neko.UserRate.put(user_id, id, Neko.UserRate.from_request(request))
  end
  defp process_action(%{id: id, user_id: user_id, action: "delete"}) do
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
