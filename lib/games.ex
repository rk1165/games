defmodule Games do
  @moduledoc """
  Documentation for `Games`.
  """
  alias Games.Wordle
  alias Games.RockPaperScissors
  alias Games.GuessingGame

  @spec main(any) :: :ok
  def main(_args) do
    play()
  end

  @spec play :: :ok
  def play() do
    choice = prompt()

    case choice do
      "1" ->
        GuessingGame.play()
        play()

      "2" ->
        RockPaperScissors.play()
        play()

      "3" ->
        Wordle.play()
        play()

      "stop" ->
        IO.puts("Thanks for playing")

      _ ->
        IO.puts("We didn't understand that. Would you like to try again?")
        play()
    end
  end

  @spec prompt :: String.t()
  def prompt() do
    IO.gets("""
    \nWhat game would you like to play?
    1. Guessing Game
    2. Rock Paper Scissors
    3. Wordle

    enter "stop" to exit
    """)
    |> String.trim()
  end
end
