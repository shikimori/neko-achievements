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

```ruby
franchise_yml = "#{ENV['HOME']}/develop/neko-achievements/priv/rules/_franchises.yml";
data = YAML.
  load_file(franchise_yml).
  each do |rule|
    recap_ids = Anime.
      where(franchise: rule['filters']['franchise']).
      select(&:kind_special?).
      select { |v| v.description_en&.match?(/\brecap\b|compilation movie/i) || v.description_ru&.match?(/\bрекап\b|\bобобщение\b/i) }.
      map(&:id)

    if recap_ids.any?
      rule['filters']['not_anime_ids'] = ((rule['filters']['not_anime_ids'] || []) + recap_ids).uniq.sort
    end
  end.
  sort_by { |v| Anime.where(franchise: v['filters']['franchise'], status: 'released').where.not(ranked: 0).map(&:ranked).min };

if data.any?
  File.open(franchise_yml, 'w') { |f| f.write data.to_yaml };
  puts data.map { |v| v['filters']['franchise'] }.join(' ');
end
```
