defmodule Games do
  @moduledoc """
  Documentation for `Games`.
  """
  alias Games.Wordle
  alias Games.RockPaperScissors
  alias Games.GuessingGame

  @spec main(any) :: nil
  def main(_args) do
    play()
  end

  @spec play :: nil
  def play() do
    choice = prompt()

    case choice do
      "1" ->
        GuessingGame.play()

      "2" ->
        RockPaperScissors.play()

      "3" ->
        Wordle.play()

      "stop" ->
        IO.puts("Thanks for playing")

      "score" ->
        IO.puts("""
        ==================================================
          Your score is #{Games.ScoreTracker.current_score()}
        ==================================================
        """)

      _ ->
        IO.puts("We didn't understand that. Would you like to try again?")
    end

    unless choice == "stop" do
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
    enter "score" to view your current score
    """)
    |> String.trim()
  end
end
