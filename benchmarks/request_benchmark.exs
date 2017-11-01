# mix run benchmarks/request_benchmark.exs
#
# TODO: blog post about elixir behaviour
# TODO: https://elixir-lang.org/getting-started/meta/quote-and-unquote.html
# TODO: https://medium.com/elixirlabs/implement-a-basic-block-yield-with-elixir-d00f313831f7
# TODO: https://github.com/spscream/ex_banking/blob/master/lib/ex_banking/application.ex
#       (declaration of Registry)
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
