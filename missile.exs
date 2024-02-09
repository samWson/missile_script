#!/usr/bin/env elixir

defmodule Game do
  def main() do
    input = IO.gets("Enter something> ")
    IO.puts("You entered: #{input}")
  end
end

Game.main()
