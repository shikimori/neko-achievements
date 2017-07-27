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

  def process(request) do
    load_user_data(request)
    process_action(request)
  end

  defp load_user_data(%{user_id: user_id}) do
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
end
