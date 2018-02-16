defmodule Neko.Router do
  # router is a plug that contains its own plug pipeline
  use Plug.Router
  use Plug.ErrorHandler

  @token "foo"

  # log request information to stdout when running tests
  plug Plug.Logger
  # token authenticaiton
  plug Neko.Plug.Authenticate, token: @token
  # finds matching route and forwards it to dispatch plug
  # (saves it in conn private field `plug_route`)
  plug :match

  plug Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Poison

  # dispatches to function body of matching route
  # (saved in conn private field `plug_route`)
  plug :dispatch

  # each route must return connection
  get "/ping" do
    conn |> send_resp(200, "pong")
  end

  get "/error" do
    raise("test error")
    conn |> send_resp(200, "never reached")
  end

  post "/user_rate" do
    request = Neko.Request.new(conn.body_params)

    request.user_id
    |> Neko.UserHandler.Supervisor.create_missing_handler()

    diff = request |> Neko.UserHandler.process()
    conn |> send_resp(201, Poison.encode!(diff))
  end

  # catch-all route
  match _ do
    conn |> send_resp(404, "oops")
  end

  # always encode response:
  #
  # - send_resp/3 expects response to be a string
  #   (while message or reason can be atoms)
  # - even if response is already a string, still encode it
  #   before sending since a raw string is not correct json
  #   (Poison.encode!("Application error") -> "\"Application error\"")
  defp handle_errors(conn, %{reason: %{message: message}}) do
    conn |> send_resp(conn.status, Poison.encode!(message))
  end

  defp handle_errors(conn, %{reason: %{reason: reason}}) do
    conn |> send_resp(conn.status, Poison.encode!(reason))
  end

  defp handle_errors(conn, %{reason: _reason}) do
    conn |> send_resp(conn.status, Poison.encode!("Application error"))
  end

  # https://docs.appsignal.com/elixir/integrations/plug.html#incoming-http-requests
  use Appsignal.Plug
end
