# neko

[![CircleCI](https://circleci.com/gh/shikimori/neko-achievements.svg?style=svg)](https://circleci.com/gh/shikimori/neko-achievements)

## local start

```sh
# with REPL
$ iex -S mix
# without REPL
$ mix run -—no-halt
```


## deploy

```sh
$ mix deploy
```


### elixir samples
```elixir
# get neko_id rules
Neko.Rule.CountRule.Store.all |> Enum.filter(&(&1.neko_id == "longshounen"))

# get animes
Neko.Anime.all()
Neko.Anime.all_by_id()


# get animes matched by rule
user_id = 1
Neko.UserRate.load(user_id)

rule = Neko.Rule.CountRule.Store.all |> Enum.filter(&(&1.neko_id == "longshounen" && &1.level == 1)) |> Enum.at(0)
rule = Neko.Rule.DurationRule.Store.all |> Enum.filter(&(&1.neko_id == "sword_art_online" && &1.level == 1)) |> Enum.at(0)

user_anime_ids = user_id |> Neko.UserRate.all() |> Enum.map(& &1.target_id) |> MapSet.new()
user_animes_by_id = Neko.Anime.all_by_id() |> Map.take(user_anime_ids)
user_anime_ids |> MapSet.intersection(rule.anime_ids)
```

### elixir logging
```elixir
  require IEx; IEx.pry

  # /lib/neko/rule/rule.ex
  defp rule_applies?({rule, value}) do
    if rule.neko_id == "teekyuu" && rule.level == 0 do
      IO.puts("Neko.Rule: applies?: #{value >= rule.threshold} value: #{value} rule.threshold: #{rule.threshold}")
    end
    value >= rule.threshold
  end

  # /lib/neko/rule/duration_rule/duration_rule.ex
  def value(rule, _user_anime_ids, by_anime_id) do
    if rule.neko_id == "sword_art_online" && rule.level == 1 do
      value = by_anime_id
        |> Map.take(rule.anime_ids)
        |> Enum.map(fn {_, %{user_rate: user_rate, anime: anime}} ->
          if user_rate.status == "watching" || user_rate.status == "on_hold" do
            anime.duration * user_rate.episodes
          else
            anime.total_duration
          end
        end)
        |> Enum.sum()

      IO.inspect rule
      IO.puts("Neko.Rule.DurationRule: value: #{value} rule.threshold: #{rule.threshold}")
    end

    by_anime_id
    |> Map.take(rule.anime_ids)
    |> Enum.map(fn {_, %{user_rate: user_rate, anime: anime}} ->
      if user_rate.status == "watching" || user_rate.status == "on_hold" do
        anime.duration * user_rate.episodes
      else
        anime.total_duration
      end
    end)
    |> Enum.sum()
  end

```

### parse achievements extracted from google docs

```ruby
File.open('/tmp/achievements.yml', 'w') { |f| f.write SmarterCSV.process(open('/tmp/achievements.csv')).to_yaml }
```

```ruby
anime_id_regexp = %r{/animes/[A-z]*(?<id>\d+)}
data = YAML.load_file('/tmp/achievements.yml').
  map do |entry|
    franchise = Anime.find(entry[:url].match(anime_id_regexp)[:id]).franchise

    if entry[:except_titles].present?
      not_anime_ids = {
        'not_anime_ids' => [
          entry[:except_titles]
        ] + entry[:except_titles].scan(anime_id_regexp).map(&:first).map(&:to_i)
      }
    end

    {
      'neko_id' => franchise,
      'level' => 1,
      'algo' => 'count',
      'filters' => {
        'franchise' => franchise,
      }.merge(not_anime_ids || {}),
      'threshold' => entry[:threshold],
      'metadata' => {
        'image' => [entry[:image_url], entry[:image_2_url], entry[:image_3_url], entry[:image_4_url]].compact
      }
    }
  end.
  sort_by { |v| Anime.where(franchise: v['filters']['franchise'], status: 'released').where.not(ranked: 0).map(&:ranked).min }

File.open("#{ENV['HOME']}/develop/neko-achievements/priv/rules/_franchises.yml", 'w') { |f| f.write data.to_yaml }

puts data.map { |v| v['filters']['franchise'] }.join(' ')
```
