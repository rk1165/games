defmodule Games do
  @moduledoc """
  Documentation for `Games`.
  """
  alias Games.ScoreTracker
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
        GuessingGame.play(:guessing_game)
        play()

      "2" ->
        RockPaperScissors.play(:rock_paper_scissors)
        play()

      "3" ->
        Wordle.play(:wordle)
        play()

      "stop" ->
        IO.puts("Thanks for playing")

      "score" ->
        IO.puts("==================================================")
        ScoreTracker.current_score(:score_tracker) |> IO.inspect()
        IO.puts("==================================================")
        play()

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
    enter "score" to view your current score
    """)
    |> String.trim()
  end
end
