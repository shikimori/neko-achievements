# https://hexdocs.pm/elixir/master/Code.html#format_string!/2-options
[
  # these packages have adopted .formatter.exs
  # => there is no need in locals_without_parens option now
  import_deps: [:ecto, :phoenix, :plug],
  inputs: ["{config,lib,test}/**/*.{ex,exs}", "mix.exs"],
  line_length: 83
]
