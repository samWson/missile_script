#!/usr/bin/env elixir

defmodule Game do
  def main() do
    loop(%{ship: :normal})
  end

  defp loop(%{command: "quit"}) do
    exit(:normal)
  end

  defp loop(%{ship: :hit}) do
    IO.puts("Missile hit ship. Game over.")
    exit(:normal)
  end

  defp loop(state) do
    # Spawn missile if it doesn't already exist
    state_with_missile = cond do
      Map.has_key?(state, :missile) ->
        state
      true ->
        # range in nautical miles from target (Players own ship position).
        # speed is how many nautical miles the missile travels in a single game turn.
        Map.put(state, :missile, %{range: 100, speed: 20})
    end

    # report
    case Map.fetch(state_with_missile, :missile) do
      {:ok, %{range: range}} -> IO.puts("Missile approaching. #{range}NM")
      :error -> nil
    end

    # prompt
    command = IO.gets("Enter command> ") |> String.trim()
    IO.puts("You entered: #{command}")
    state_with_command = Map.put(state_with_missile, :command, command)

    # process
    processed_state = case Map.fetch(state_with_command, :missile) do
      {:ok, %{range: 0}} ->
        %{state_with_command | ship: :hit}
      {:ok, missile} ->
        new_range = missile[:range] - missile[:speed]
        %{state_with_command | missile: %{range: new_range, speed: missile[:speed]}}
      :error ->
        state_with_command
    end

    loop(processed_state)
  end
end

Game.main()
