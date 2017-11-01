# mix run benchmarks/request_benchmark.exs
#
# TODO: https://elixir-lang.org/getting-started/meta/quote-and-unquote.html
# TODO: https://medium.com/elixirlabs/implement-a-basic-block-yield-with-elixir-d00f313831f7
defmodule RequestBenchmark do
  def run do
    user_id = 1
    setup(user_id)

    request = %Neko.Request{user_id: user_id, action: "noop"}
    diff = Neko.Request.process(request)

    IO.inspect(diff)
  end

  defp setup(user_id) do
    Application.ensure_all_started(:neko)

    # set application environment dynamically:
    # use mock client but real rules
    Application.put_env(
      :neko,
      :shikimori_client,
      Neko.Shikimori.MockClient,
      persistent: true
    )
    Application.put_env(
      :neko,
      :rules,
      [dir: "priv/rules", list: [Neko.Rules.SimpleRule]],
      persistent: true
    )

    Neko.UserRate.load(user_id)
    Neko.Achievement.load(user_id)

    Neko.Anime.set(animes())
    Neko.UserRate.set(user_id, user_rates())
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

RequestBenchmark.run()
