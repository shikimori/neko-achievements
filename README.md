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


#### Sort franchsies

```ruby
franchise_yml = "#{ENV['HOME']}/develop/neko-achievements/priv/rules/_franchises.yml";
data = YAML.
  load_file(franchise_yml).
  sort_by do |v|
    rating = Anime.where(franchise: v['filters']['franchise'], status: 'released').where.not(ranked: 0).map(&:ranked).min
    raise "#{v['filters']['franchise']} rating is nil" if rating.nil?
    rating
  end

if data.any?
  File.open(franchise_yml, 'w') { |f| f.write data.to_yaml };
  puts data.map { |v| v['filters']['franchise'] }.join(' ');
end
```


#### Cleanup recaps and picture dramas

```ruby
franchise_yml = "#{ENV['HOME']}/develop/neko-achievements/priv/rules/_franchises.yml";
ALLOWED_SPECIAL_IDS = [15711, 2269, 14007, 20667, 24371, 2336]

data = YAML.
  load_file(franchise_yml).
  each do |rule|
    recap_ids = Anime.
      where(franchise: rule['filters']['franchise']).
      select(&:kind_special?).
      select do |v|
        next if ALLOWED_SPECIAL_IDS.include?(v.id)
        v.name.match?(/\brecaps?\b|compilation movie|picture drama/i) ||
          v.description_en&.match?(/\brecaps?\b|compilation movie|picture drama/i) ||
          v.description_ru&.match?(/\bрекап\b|\bобобщение\b|\bчиби\b|краткое содержание/i)
      end.
      map(&:id)

    if recap_ids.any?
      rule['filters']['not_anime_ids'] = ((rule['filters']['not_anime_ids'] || []) + recap_ids).uniq.sort
    end
  end.
  sort_by do |v|
    rating = Anime.where(franchise: v['filters']['franchise'], status: 'released').where.not(ranked: 0).map(&:ranked).min
    raise "#{v['filters']['franchise']} rating is nil" if rating.nil?
    rating
  end

if data.any?
  File.open(franchise_yml, 'w') { |f| f.write data.to_yaml };
  puts data.map { |v| v['filters']['franchise'] }.join(' ');
end
```


#### Subtract specials and ova

```ruby
franchise_yml = "#{ENV['HOME']}/develop/neko-achievements/priv/rules/_franchises.yml";
raw_data = YAML.load_file(franchise_yml);

HARDCODED_THRESHOLD = {
  ehon_yose: 50
}

data = raw_data.dup.each do |rule|
  franchise = Anime.where(franchise: rule['filters']['franchise'])
  if rule['filters']['not_anime_ids'].present?
    franchise = franchise.where.not(id: rule['filters']['not_anime_ids'])
  end
  ova = franchise.select(&:kind_ova?)
  long_specials = franchise.select(&:kind_special?).select { |v| v.duration >= 22 }
  short_specials = franchise.select(&:kind_special?).select { |v| v.duration < 22 && v.duration > 5 }
  mini_specials = (franchise.select(&:kind_special?) + franchise.select(&:kind_ona?)).select { |v| v.duration <= 5 }

  total_duration = franchise.sum { |v| v.duration * v.episodes }
  ova_duration = ova.sum { |v| v.duration * v.episodes }
  long_specials_duration = long_specials.sum { |v| v.duration * v.episodes }
  short_specials_duration = short_specials.sum { |v| v.duration * v.episodes }
  mini_specials_duration = mini_specials.sum { |v| v.duration * v.episodes }

  ova_duration_subtract = 
    if ova_duration * 1.0 / total_duration <= 0.1 && franchise.size > 5 && ova.size > 2
      ova_duration / 2
    else
      0
    end

  long_specials_duration_subtract =
    if long_specials_duration * 1.0 / total_duration <= 0.1
      (long_specials.size > 2 ? long_specials_duration / 2.0 : long_specials_duration)
    else
      0
    end

  short_specials_duration_subtract = short_specials.size <= 3 ? short_specials_duration : short_specials_duration / 2.0

  threshold = (
    total_duration -
    ova_duration_subtract -
    long_specials_duration_subtract -
    short_specials_duration_subtract -
    mini_specials_duration
  ) * 100.0 / total_duration

  if total_duration > 20_000
    threshold = [60, threshold].min
  end

  if total_duration > 10_000
    threshold = [80, threshold].min
  end

  if total_duration > 5_000
    threshold = [90, threshold].min
  end

  if franchise.size >= 7 || total_duration > 5_000
    threshold = [95, threshold].min
  end

  animes_with_year = franchise.reject(&:kind_special?).select(&:year)
  average_year = animes_with_year.sum(&:year) * 1.0 / animes_with_year.size
  if average_year < 1987
    threshold -= 15
  elsif average_year < 1991
    threshold -= 10
  elsif average_year < 1996
    threshold -= 5
  end

  ap(
    franchise: rule['filters']['franchise'],
    #threshold: rule['threshold'].gsub('%', '').to_f,
    new_threshold: threshold.floor(1)
  )
  rule['threshold'] = "#{HARDCODED_THRESHOLD[rule['filters']['franchise'].to_sym] || threshold.floor(1)}%".gsub(/\.0%$/, '%')
end;

if data.any?
  File.open(franchise_yml, 'w') { |f| f.write data.to_yaml };
  puts data.map { |v| v['filters']['franchise'] }.join(' ');
end
```
