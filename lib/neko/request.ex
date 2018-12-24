defmodule Neko.Request do
  defstruct ~w(
    id
    user_id
    target_id
    score
    action
    status
    episodes
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

  @await_timeout Application.get_env(:neko, :shikimori)[:total_timeout]

  def process(%{user_id: user_id} = request) do
    load_user_data(request)
    process_action(request)

    new_achievements = calc_new_achievements(user_id)
    diff = calc_diff(user_id, new_achievements)
    save_new_achievements(user_id, new_achievements)

    diff
  end

  # prior to processing requests inside user handler processes any
  # error in a linked task to load achievements or user rates
  # (spawned with Task.async) crashed the caller (request process)
  # without invoking Plug.ErrorHandler callback (handler_errors/2)
  # and sending proper response to the client.
  #
  # now requests are processed inside long-running user handler
  # processes: any error inside linked task first crashes immediate
  # caller (user handler process) and then request process itself
  # (since they are also linked) but, unlike before, Plug.ErrorHandler
  # callback is now invoked and proper response with status code 500
  # and error message is sent to the client.
  defp load_user_data(%{user_id: user_id, action: "reset"}) do
    [
      Task.async(Neko.UserRate, :reload, [user_id]),
      Task.async(Neko.Achievement, :reload, [user_id])
    ]
    |> Enum.map(&Task.await(&1, @await_timeout))
  end

  defp load_user_data(%{user_id: user_id}) do
    [Neko.UserRate, Neko.Achievement]
    |> Enum.map(&Task.async(&1, :load, [user_id]))
    |> Enum.map(&Task.await(&1, @await_timeout))
  end

  defp process_action(%{action: "noop"}) do
    # nothing to do
  end

  defp process_action(%{action: "reset"}) do
    # nothing to do
  end

  defp process_action(%{action: "put", status: status} = request)
       when status in ["completed", "rewatching", "watching"] do
    request.user_id
    |> Neko.UserRate.put(Neko.UserRate.from_request(request))
  end

  # if user rate becomes not "completed", "rewatching" or "watching",
  # it's removed
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
