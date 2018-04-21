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


### parse achievements extracted from google docs
```ryby
File.open('/tmp/achievements.yml', 'w') {|f| f.write SmarterCSV.process(open('/tmp/achievements.csv')).to_yaml }
```

```ryby
data = YAML.load_file('/tmp/achievements.yml').
  map do |entry|
    franchise = Anime.find(entry[:url].match(%r{/animes/[A-z]*(?<id>\d+)})[:id]).franchise

    {
      neko_id: franchise,
      level: 1,
      algo: 'simple',
      filters: {
        franchise: franchise,
      },
      threshold: entry[:threshold].to_i,
      metadata: {
        image: [entry[:image_url], entry[:image_2_url], entry[:image_3_url], entry[:image_4_url]].compact
      }
    }
  end.
  sort_by { |v| Anime.where(franchise: v[:filters][:franchise], status: 'released').where.not(ranked: 0).map(&:ranked).min }

File.open("#{ENV['HOME']}/develop/neko-achievements/priv/rules/_franchises.yml", 'w') {|f| f.write data.to_yaml }

puts data.map { |v| v[:filters][:franchise] }.join(' ')
```
