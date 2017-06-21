defmodule Neko.Router do
  # router is a plug that contains its own plug pipeline
  use Plug.Router

  @token "foo"

  plug Neko.Plug.Authenticate, token: @token
  plug Plug.Logger
  plug :match
  plug :dispatch

  get "/ping" do
    conn |> send_resp(200, "pong")
  end

  post "/user_rate" do
    {:ok, body, _conn} = read_body(conn)
    # TODO: create struct to store user rate action
    # TODO: parse body into that struct using Poison
    # TODO: add router test (https://github.com/elixir-lang/plug#testing-plugs)
    #
    # https://hexdocs.pm/plug/Plug.Router.html#module-parameter-parsing
    # https://stackoverflow.com/questions/34476915
    result = "result"
    conn |> send_resp(201, result)
  end

  match _ do
    conn |> send_resp(404, "oops")
  end
end
