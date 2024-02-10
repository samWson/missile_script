#!/usr/bin/env elixir

defmodule Game do
  def main() do
    loop(%{})
  end

  defp loop(%{command: "quit"}) do
    exit(:normal)
  end

  defp loop(state) do
    # {range in nautical miles}
    missile = {100}

    state_with_missile = Map.put(state, :missile, missile)

    case Map.fetch(state_with_missile, :missile) do
      {:ok, {range}} -> IO.puts("Missile approaching. #{range}NM")
      :error -> nil
    end

    command = IO.gets("Enter something> ") |> String.trim()
    IO.puts("You entered: #{command}")

    state_with_command = Map.put(state_with_missile, :command, command)

    loop(state_with_command)
  end
end

Game.main()
