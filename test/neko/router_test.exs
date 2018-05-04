# credo:disable-for-this-file Credo.Check.Refactor.PipeChainStart

# https://elixirschool.com/lessons/specifics/plug/#testing-a-plug
# https://github.com/elixir-lang/plug/blob/master/test/plug/parsers/json_test.exs
defmodule Neko.RouterTest do
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
  use ExUnit.Case, async: false
  use Plug.Test

  alias Neko.Router
  alias Neko.{Achievement, Anime, Request, UserRate}
  alias Neko.Rules.SimpleRule

  @opts Router.init([])

  # all custom options will be merged into the context which is
  # a map containing either all information about current test
  # (for setup) or information that is common for all tests in
  # current module (for setup_all).
  #
  # map keys are tags automatically set by ExUnit,
  # sample context passed to each test from setup block:
  #
  # %{async: true, case: Neko.RouterTest, describe: "/user_rate",
  #  file: <filename>, line: 25, registered: %{}, test: <testname>,
  #  type: :test, request: <request>}
  setup_all do
    user_id = 1

    UserRate.load(user_id)
    Achievement.load(user_id)

    {:ok, user_id: user_id}
  end

  # contexts returned from both setup_all and setup blocks are
  # merged into final context which is available in each test
  #
  # set animes and simple rules on per test basis - or else the
  # 1st test might fetch animes set in another test instead of
  # animes set here (tests are run in random order).
  setup do
    Anime.set([
      %Anime{id: 1},
      %Anime{id: 2},
      %Anime{id: 3},
      %Anime{id: 4},
      %Anime{id: 5}
    ])

    SimpleRule.set([
      %SimpleRule{neko_id: "animelist", level: 1, threshold: 2},
      %SimpleRule{neko_id: "animelist", level: 2, threshold: 4},
      %SimpleRule{neko_id: "animelist", level: 3, threshold: 10}
    ])
  end

  test "add next level achievement", %{user_id: user_id} do
    UserRate.set(
      user_id,
      [
        %UserRate{id: 1, user_id: user_id, target_id: 1, status: "completed"},
        %UserRate{id: 2, user_id: user_id, target_id: 2, status: "completed"},
        %UserRate{id: 3, user_id: user_id, target_id: 3, status: "completed"}
      ]
    )

    Achievement.set(
      user_id,
      [
        %Achievement{
          user_id: user_id,
          neko_id: "animelist",
          level: 1,
          progress: 50
        }
      ]
    )

    json =
      %Request{
        id: 4,
        user_id: user_id,
        target_id: 4,
        status: "completed",
        action: "put"
      }
      |> Poison.encode!()

    conn =
      "/user_rate"
      |> json_post_conn(json)
      |> Router.call(@opts)

    expected_body =
      %{
        added: [
          %Achievement{
            user_id: user_id,
            neko_id: "animelist",
            level: 2,
            progress: 0
          }
        ],
        removed: [],
        updated: [
          %Achievement{
            user_id: user_id,
            neko_id: "animelist",
            level: 1,
            progress: 100
          }
        ]
      }
      |> Poison.encode!()

    assert conn.state == :sent
    assert conn.status == 201
    assert conn.resp_body == expected_body
  end

  test "remove achievement (absolute threshold)", %{user_id: user_id} do
    UserRate.set(
      user_id,
      [
        %UserRate{id: 1, user_id: user_id, target_id: 1, status: "completed"},
        %UserRate{id: 2, user_id: user_id, target_id: 2, status: "completed"}
      ]
    )

    Achievement.set(
      user_id,
      [
        %Achievement{
          user_id: user_id,
          neko_id: "animelist",
          level: 1,
          progress: 0
        }
      ]
    )

    json =
      %Request{
        id: 2,
        user_id: user_id,
        target_id: 2,
        action: "delete"
      }
      |> Poison.encode!()

    conn =
      "/user_rate"
      |> json_post_conn(json)
      |> Router.call(@opts)

    expected_body =
      %{
        added: [],
        removed: [
          %Achievement{
            user_id: user_id,
            neko_id: "animelist",
            level: 1,
            progress: 0
          }
        ],
        updated: []
      }
      |> Poison.encode!()

    assert conn.state == :sent
    assert conn.status == 201
    assert conn.resp_body == expected_body
  end

  test "remove achievement (percent threshold)", %{user_id: user_id} do
    Anime.set([
      %Anime{id: 1, franchise: "hikaru_no_go"},
      %Anime{id: 2, franchise: "hikaru_no_go"},
      %Anime{id: 3, franchise: "hikaru_no_go"}
    ])

    SimpleRule.set([
      %SimpleRule{
        neko_id: "hikaru_no_go",
        level: 1,
        threshold: "100%",
        filters: %{
          franchise: "hikaru_no_go"
        }
      }
    ])

    UserRate.set(
      user_id,
      [
        %UserRate{id: 1, user_id: user_id, target_id: 1, status: "completed"},
        %UserRate{id: 2, user_id: user_id, target_id: 2, status: "completed"},
        %UserRate{id: 3, user_id: user_id, target_id: 3, status: "completed"}
      ]
    )

    Achievement.set(
      user_id,
      [
        %Achievement{
          user_id: user_id,
          neko_id: "hikaru_no_go",
          level: 1,
          progress: 100
        }
      ]
    )

    json =
      %Request{
        id: 3,
        user_id: user_id,
        target_id: 3,
        action: "put",
        status: "planned"
      }
      |> Poison.encode!()

    conn =
      "/user_rate"
      |> json_post_conn(json)
      |> Router.call(@opts)

    expected_body =
      %{
        added: [],
        removed: [
          %Achievement{
            user_id: user_id,
            neko_id: "hikaru_no_go",
            level: 1,
            progress: 100
          }
        ],
        updated: []
      }
      |> Poison.encode!()

    assert conn.state == :sent
    assert conn.status == 201
    assert conn.resp_body == expected_body
  end

  test "get page without authorization token" do
    json = %Request{} |> Poison.encode!()
    conn =
      "/user_rate"
      |> json_post_conn(json)
      |> put_req_header("authorization", "bar")
      |> Router.call(@opts)

    assert conn.state == :sent
    assert conn.status == 401
    assert conn.resp_body == "Not Authorized"
  end

  test "get missing page" do
    json = %Request{} |> Poison.encode!()
    conn =
      "/missing"
      |> json_post_conn(json)
      |> Router.call(@opts)

    assert conn.state == :sent
    assert conn.status == 404
    assert conn.resp_body == "oops"
  end

  defp json_post_conn(path, json) do
    conn(:post, path, json)
    |> put_req_header("content-type", "application/json")
    |> put_req_header("authorization", "foo")
  end
end
