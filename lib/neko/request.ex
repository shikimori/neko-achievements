defmodule Neko.Request do
  defstruct ~w(
    id
    user_id
    target_id
    score
    status
    action
  )a

  # NOTE: use ExConstructor after defstruct
  #
  # options determine what type of keys are
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

    new_achievements = calc_new_achievements(user_id)
    diff = calc_diff(user_id, new_achievements)
    save_new_achievements(user_id, new_achievements)

    diff
  end

  defp preprocess_action(%{user_id: user_id, action: "reset"}) do
    Neko.UserRate.reset(user_id)
  end
  defp preprocess_action(%{action: _action}) do
    # nothing to do for other actions
  end

  # https://gist.github.com/moklett/d30fc2dbaf71f3b978da115f8a5f8387
  # unlike Task.await/2, Task.yield/2 doesn't crash the caller
  # if the task crashes (task must be not linked to the caller)
  defp load_user_data(user_id) do
    [Neko.Achievement, Neko.UserRate]
    |> Enum.map(fn(x) ->
      sup_pid = Neko.TaskSupervisor
      Task.Supervisor.async_nolink(sup_pid, x, :load, [user_id])
    end)
    |> Enum.map(&Task.yield/1)
    |> Enum.each(fn
      {:ok, _result} -> :ok
      {:exit, {error, _stack}} -> raise(error)
      nil -> raise("timeout loading user data")
    end)
  end

  defp process_action(%{action: "noop"}) do
  end
  defp process_action(%{action: "reset"}) do
    # user rates are reset in preprocess_action
    # and then loaded in load_user_data
  end
  defp process_action(%{action: "put", status: "completed"} = request) do
    request.user_id
    |> Neko.UserRate.put(Neko.UserRate.from_request(request))
  end
  defp process_action(%{action: "put"} = request) do
    request.user_id
    |> Neko.UserRate.delete(Neko.UserRate.from_request(request))
  end
  defp process_action(%{action: "delete"} = request) do
    request.user_id
    |> Neko.UserRate.delete(Neko.UserRate.from_request(request))
  end

  defp calc_new_achievements(user_id) do
    Neko.Achievement.Calculator.call(user_id)
  end

  defp calc_diff(user_id, new_achievements) do
    user_id
    |> Neko.Achievement.all()
    |> Neko.Achievement.Diff.call(new_achievements)
  end

  defp save_new_achievements(user_id, achievements) do
    Neko.Achievement.set(user_id, achievements)
  end
end
