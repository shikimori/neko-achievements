[
  # uncomment when plug package adopts .formatter.exs
  #import_deps: [:plug],
  inputs: ["{config,lib,test}/**/*.{ex,exs}", "mix.exs"],
  line_length: 83,
  locals_without_parens: [plug: 1, plug: 2]
]
