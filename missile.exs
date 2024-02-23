#!/usr/bin/env elixir

defmodule Missile do
  # range in nautical miles from target (Players own ship position).
  # speed is how many nautical miles the missile travels in a single game turn.
  defstruct range: 0, speed: 20, state: :normal
  @type t :: %__MODULE__{range: non_neg_integer(), speed: non_neg_integer(), state: atom()}
end

defmodule Game do
  def main() do
    loop(%{ship: :normal})
  end

  defp loop(state = %{command: "launch interceptor"}) do
    # An interceptor behaves like a missile but starts at the ship (range 0) and
    # flies toward the incoming missile (range increases each turn).
    new_state = Map.put(state, :interceptor, %Missile{speed: 40})

    loop(%{new_state | command: ""})
  end

  defp loop(%{command: "quit"}) do
    exit(:normal)
  end

  defp loop(state = %{command: "skip"}) do
    loop(%{state | command: ""})
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
        Map.put(state, :missile, %Missile{range: 100})
    end
  end

  defp report(state) do
    case Map.fetch(state, :missile) do
      {:ok, %{state: :hit}} ->
        IO.puts("Missile destroyed")
        state
      {:ok, %{range: range}} ->
        IO.puts("Missile approaching: #{range}NM")
        state
      :error ->
        state
    end

    case Map.fetch(state, :interceptor) do
      {:ok, %{state: :hit}} ->
        state
      {:ok, %{range: range}} ->
        IO.puts("Inteceptor outgoing: #{range}NM")
        state
      :error ->
        state
    end

    state
  end

  defp prompt(state) do
    command = IO.gets("Enter command> ") |> String.trim()
    IO.puts("You entered: #{command}")

    Map.put(state, :command, command)
  end

  defp process_turn(state) do
    new_state = case Map.fetch(state, :missile) do
      {:ok, %{range: 0}} ->
        %{state | ship: :hit}
      {:ok, missile} ->
        new_range = missile.range - missile.speed
        %{state | missile: %Missile{range: new_range, speed: missile.speed}}
      :error ->
        state
    end

    final_state = case Map.fetch(new_state, :interceptor) do
      {:ok, interceptor} ->
        new_range = interceptor.range + interceptor.speed
        %{new_state | interceptor: %Missile{range: new_range, speed: interceptor.speed}}
      :error ->
        new_state
    end

    missile = Map.get(final_state, :missile)
    interceptor = Map.get(final_state, :interceptor)

    cond do
      is_nil(missile) ->
        final_state
      is_nil(interceptor) ->
        final_state
      missile.range > interceptor.range ->
        final_state
      missile.range <= interceptor.range ->
        updated_missile = %Missile{missile | state: :hit}
        updated_interceptor = %Missile{interceptor | state: :hit}
        %{final_state | missile: updated_missile, interceptor: updated_interceptor}
      true ->
        final_state
    end
  end
end

Game.main()
