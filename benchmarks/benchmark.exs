# https://stackoverflow.com/a/29674651/3632318
# https://medium.com/elixirlabs/implement-a-basic-block-yield-with-elixir-d00f313831f7
defmodule Benchmark do
  def measure(function) do
    function
    |> :timer.tc
    |> elem(0)
    |> Kernel./(1_000)
  end

  def setup(user_id) do
    Application.ensure_all_started(:neko)

    Neko.Anime.set(animes())
    Neko.Rules.SimpleRule.set(simple_rules())

    # load user rates and achievements first -
    # otherwise set/1 will raise error
    Neko.UserRate.load(user_id)
    Neko.Achievement.load(user_id)

    Neko.UserRate.set(user_id, user_rates())
    # achievements are left empty
  end

  defp animes do
    "priv/dumps/animes.json"
    |> File.read!()
    |> Poison.decode!(as: [%Neko.Anime{}])
    |> MapSet.new()
  end

  defp simple_rules do
    "simple"
    |> Neko.Rules.Reader.read_rules()
    |> MapSet.new()
  end

  defp user_rates do
    "priv/dumps/user_rates_1.json"
    |> File.read!()
    |> Poison.decode!(as: [%Neko.UserRate{}])
    |> MapSet.new()
  end
end
