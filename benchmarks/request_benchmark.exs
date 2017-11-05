# MIX_ENV=test mix run benchmarks/request_benchmark.exs
#
# when using IEx.pry:
# MIX_ENV=test \iex -S mix run benchmarks/request_benchmark.exs

Code.require_file("benchmarks/benchmark.exs")

defmodule RequestBenchmark do
  def run(user_id) do
    request = %Neko.Request{user_id: user_id, action: "noop"}
    Neko.Request.process(request)
  end
end

# exclude setup from benchmark
user_id = 1
Benchmark.setup(user_id)

milliseconds = Benchmark.measure(fn ->
  RequestBenchmark.run(user_id)
end)

IO.puts("#{milliseconds} milliseconds")
