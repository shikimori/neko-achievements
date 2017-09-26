# neko

## local start
```sh
# ~/.zshrc
# alias iex='iex -S mix'
# with REPL
iex -S mix
# without REPL
mix run —no-halt
```

## deploy
```sh
mix edeliver update production && ssh shiki sudo systemctl restart neko
mix edeliver ping production
```
