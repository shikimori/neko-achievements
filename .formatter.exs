[
  # uncomment these packages adopt .formatter.exs
  #import_deps: [:ecto, :phoenix, :plug],
  inputs: ["{config,lib,test}/**/*.{ex,exs}", "mix.exs"],
  line_length: 83,
  locals_without_parens: [
    action_fallback: 1,
    belongs_to: 2,
    defenum: 2,
    embeds_one: 2,
    embeds_one: 3,
    field: 2,
    field: 3,
    get: 3,
    has_many: 2,
    pipe_through: 1,
    plug: 1,
    plug: 2,
    post: 3,
    raise: 1,
    resources: 3,
    socket: 2,
    timestamps: 1,
    transport: 2
  ]
]
