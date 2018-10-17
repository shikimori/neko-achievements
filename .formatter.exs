# https://hexdocs.pm/elixir/master/Code.html#format_string!/2-options
[
  # these packages have adopted .formatter.exs
  # => there is no need in locals_without_parens option now
  import_deps: [:plug],
  inputs: ["{config,lib,test}/**/*.{ex,exs}", "mix.exs"],
  line_length: 80,
  locals_without_parens: [
    defenum: 2,
    # added in Phoenix master but not in current release:
    action_fallback: 1,
    pipe_through: 1,
    resources: 3,
    socket: 2,
    transport: 2
  ]
]
