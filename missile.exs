#!/usr/bin/env elixir

defmodule Game do
  def main() do
    loop(%{})
  end

  defp loop(%{input: "quit"}) do
    exit(:normal)
  end

  defp loop(state) do
    input = IO.gets("Enter something> ") |> String.trim()
    IO.puts("You entered: #{input}")

    new_state = Map.put(state, :input, input)

    loop(new_state)
  end
end

Game.main()
