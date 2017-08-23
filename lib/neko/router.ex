defmodule Neko.Router do
  # router is a plug that contains its own plug pipeline
  use Plug.Router

  # TODO: extract it to something like secrets.yml
  @token "foo"

  # log request information to stdout when running tests
  plug Plug.Logger
  # token authenticaiton
  plug Neko.Plug.Authenticate, token: @token
  # finds matching route and forwards it to dispatch plug
  # (saves it in conn private field `plug_route`)
  plug :match
  plug Plug.Parsers, parsers: [:json],
    pass: ["application/json"],
    json_decoder: Poison
  # dispatches to function body of matching route
  # (saved in conn private field `plug_route`)
  plug :dispatch

  # each route must return connection
  get "/ping" do
    conn |> send_resp(200, "pong")
  end

  post "/user_rate" do
    # without using Plug.Parsers plug:
    #{:ok, body, _conn} = read_body(conn)
    #request = Poison.decode!(body, as: %Neko.Request{})

    request = Neko.Request.new(conn.body_params)
    request |> Neko.Request.process()
    achievements = Neko.Achievement.Calculator.call(request.user_id)

    # TODO: create 2 implementations of calculator -
    # for test and other envs (just like for shikimori api client)
    # see https://medium.com/@lasseebert/mocks-in-elixir-7204f8cc9d0f
    conn |> send_resp(201, Poison.encode!(achievements))
  end

  # catch-all route
  match _ do
    conn |> send_resp(404, "oops")
  end
end
