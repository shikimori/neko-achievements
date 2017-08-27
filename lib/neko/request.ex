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

  alias Neko.UserRate.Store
  alias Neko.UserRate.Store.Registry

  def process(%{user_id: user_id} = request) do
    load_user_data(user_id)
    process_action(request)

    new_achievements = calculate_achievements(user_id)
    deltas = calculate_deltas(new_achievements, user_id)
    save_new_achievements(user_id, new_achievements)

    deltas
  end

  defp load_user_data(user_id) do
    [
      Task.async(fn -> Neko.Achievement.load(user_id) end),
      Task.async(fn -> Neko.UserRate.load(user_id) end)
    ]
    |> Enum.map(&Task.await/1)
  end

  defp process_action(request) do
    {:ok, store_pid} = Registry.lookup(request.user_id)
    process_action(store_pid, request)
  end
  defp process_action(store_pid, %{action: "create"} = request) do
    Store.put(store_pid, request.id, Neko.UserRate.from_request(request))
  end
  defp process_action(store_pid, %{action: "update"} = request) do
    Store.update(store_pid, request.id, Map.from_struct(request))
  end
  defp process_action(store_pid, %{action: "destroy"} = request) do
    Store.delete(store_pid, request.id)
  end

  defp calculate_achievements(user_id) do
    Neko.Achievement.Calculator.call(user_id)
  end

  # TODO: optimize calculating deltas!
  defp calculate_deltas(new_achievements, user_id) do
    old_achievements = Neko.Achievement.all(user_id)

    %{
      added: added_achievements(new_achievements, old_achievements),
      removed: removed_achievements(new_achievements, old_achievements),
      updated: updated_achievements(new_achievements, old_achievements)
    }
  end

  defp added_achievements(new_achievements, old_achievements) do
    Enum.reduce(old_achievements, new_achievements, fn(x, acc) ->
      Enum.reject(acc, fn(v) ->
        v.neko_id == x.neko_id and v.level == x.level
      end)
    end)
  end

  defp removed_achievements(new_achievements, old_achievements) do
    Enum.reduce(new_achievements, old_achievements, fn(x, acc) ->
      Enum.reject(acc, fn(v) ->
        v.neko_id == x.neko_id and v.level == x.level
      end)
    end)
  end

  defp updated_achievements(new_achievements, old_achievements) do
    Enum.reduce(old_achievements, new_achievements, fn(x, acc) ->
      Enum.reject(acc, fn(v) ->
        v.neko_id == x.neko_id and
          v.level == x.level and
          v.progress == x.progress
      end)
    end)
  end

  defp save_new_achievements(user_id, achievements) do
    Neko.Achievement.set(user_id, achievements)
  end
end
