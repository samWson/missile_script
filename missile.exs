#!/usr/bin/env elixir

defmodule Game do
  def main() do
    loop(%{ship: :normal})
  end

  defp loop(state = %{command: "skip"}) do
    loop(%{state | command: ""})
  end

  defp loop(%{command: "quit"}) do
    exit(:normal)
  end

  defp loop(%{ship: :hit}) do
    IO.puts("Missile hit ship. Game over.")
    exit(:normal)
  end

  defp loop(state) do
    state
    |> spawn_missile()
    |> report()
    |> prompt()
    |> process_turn()
    |> loop()
  end

  # Spawn missile if it doesn't already exist
  defp spawn_missile(state) do
    cond do
      Map.has_key?(state, :missile) ->
        state
      true ->
        # range in nautical miles from target (Players own ship position).
        # speed is how many nautical miles the missile travels in a single game turn.
        Map.put(state, :missile, %{range: 100, speed: 20})
    end
  end

  defp report(state) do
    case Map.fetch(state, :missile) do
      {:ok, %{range: range}} ->
        IO.puts("Missile approaching. #{range}NM")
        state
      :error ->
        state
    end
  end

  defp prompt(state) do
    command = IO.gets("Enter command> ") |> String.trim()
    IO.puts("You entered: #{command}")

    Map.put(state, :command, command)
  end

  defp process_turn(state) do
    case Map.fetch(state, :missile) do
      {:ok, %{range: 0}} ->
        %{state | ship: :hit}
      {:ok, missile} ->
        new_range = missile[:range] - missile[:speed]
        %{state | missile: %{range: new_range, speed: missile[:speed]}}
      :error ->
        state
    end
  end
end

Game.main()
