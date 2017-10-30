# https://elixirschool.com/lessons/specifics/plug/#testing-a-plug
# https://github.com/elixir-lang/plug/blob/master/test/plug/parsers/json_test.exs
defmodule Neko.RouterTest do
  use ExUnit.Case, async: false
  use Plug.Test

  alias Neko.Router

  @opts Router.init([])

  # common setup for all describe blocks
  #
  # the problem with registering gen servers of store registries
  # using their module names:
  #
  # can we use `async: true` here? it's okay with anime store
  # since it's read-only but achievements and user rates are
  # changed in store (stores are accessed by user_id so it's
  # a problem if user_ids are the same) => use `async: false`
  #
  # this can be fixed by starting store registries with unique
  # names in application.exs - that is don't start registries
  # as part of supervision tree but do it here providing unique
  # names (just like in registry tests)
  setup_all do
    user_id = 1

    Neko.UserRate.load(user_id)
    Neko.Achievement.load(user_id)

    # all custom options will be merged into the context which is
    # a map containing all the information about current test
    # (keys of this map are tags automatically set by ExUnit), e.g.:
    #
    # %{async: true, case: Neko.RouterTest, describe: "/user_rate",
    #  file: <filename>, line: 25, registered: %{}, test: <testname>,
    #  type: :test, request: <request>}
    {:ok, user_id: user_id}
  end

  describe "/user_rate" do
    setup %{user_id: user_id} do
      anime_1_id = 1
      anime_2_id = 2
      anime_3_id = 3

      Neko.Anime.set(
        [%Neko.Anime{id: anime_1_id},
        %Neko.Anime{id: anime_2_id},
        %Neko.Anime{id: anime_3_id}]
      )

      Neko.UserRate.set(
        user_id,
        [%Neko.UserRate{id: 1, user_id: user_id, target_id: anime_1_id},
        %Neko.UserRate{id: 2, user_id: user_id, target_id: anime_2_id}]
      )

      Neko.Achievement.set(
        user_id,
        [%Neko.Achievement{user_id: user_id, neko_id: "animelist",
          level: 1, progress: 50}]
      )

      request = %Neko.Request{
        id: 3,
        user_id: user_id,
        target_id: anime_3_id,
        score: 10,
        status: "completed",
        action: "put"
      }

      {:ok, request: request}
    end

    test "returns new achievements", context do
      json = Poison.encode!(context.request)
      conn =
        json_post_conn("/user_rate", json)
        |> Router.call(@opts)

      assert conn.state == :sent
      assert conn.status == 201
      assert conn.resp_body == Poison.encode!(
        %{
          added: MapSet.new([
            %Neko.Achievement{user_id: context.user_id,
              neko_id: "animelist", level: 2, progress: 0}
          ]),
          removed: MapSet.new(),
          updated: MapSet.new([
            %Neko.Achievement{user_id: context.user_id,
              neko_id: "animelist", level: 1, progress: 100}
          ])
        }
      )
    end

    test "returns 401 without authorization token", context do
      json = Poison.encode!(context.request)
      conn =
        json_post_conn("/user_rate", json)
        |> put_req_header("authorization", "bar")
        |> Router.call(@opts)

      assert conn.state == :sent
      assert conn.status == 401
      assert conn.resp_body == "Not Authorized"
    end

    test "returns 404 for missing page", context do
      json = Poison.encode!(context.request)
      conn = json_post_conn("/missing", json) |> Router.call(@opts)

      assert conn.state == :sent
      assert conn.status == 404
      assert conn.resp_body == "oops"
    end
  end

  describe "load testing /user_rate" do
    setup %{user_id: user_id} do
      Neko.Anime.set(animes())
      Neko.UserRate.set(user_id, user_rates())

      request = %Neko.Request{
        user_id: user_id,
        action: "reset"
      }

      {:ok, request: request}
    end

    test "returns new achievements", context do
      json = Poison.encode!(context.request)
      conn =
        json_post_conn("/user_rate", json)
        |> Router.call(@opts)

      assert conn.state == :sent
      assert conn.status == 201
    end
  end

  defp json_post_conn(path, json) do
    conn(:post, path, json)
    |> put_req_header("content-type", "application/json")
    |> put_req_header("authorization", "foo")
  end

  defp animes do
    "priv/dumps/animes.json"
    |> File.read!()
    |> Poison.decode!(as: [%Neko.Anime{}])
  end

  defp user_rates do
    "priv/dumps/user_rates_1.json"
    |> File.read!()
    |> Poison.decode!(as: [%Neko.UserRate{}])
  end
end
