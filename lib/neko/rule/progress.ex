defmodule Neko.Rule.Progress do
  def progress(%{next_threshold: nil}, _value) do
    100
  end

  def progress(%{threshold: threshold}, value)
       when value == threshold do
    0
  end

  def progress(%{next_threshold: next_threshold}, value)
       when value >= next_threshold do
    100
  end

  def progress(rule, value) do
    %{threshold: threshold, next_threshold: next_threshold} = rule
    progress = (value - threshold) / (next_threshold - threshold) * 100
    progress |> Float.floor()
  end
end
