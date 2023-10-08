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
        {:ok, pid} = GuessingGame.start()
        GuessingGame.play(pid)
        play()

      "2" ->
        {:ok, pid} = RockPaperScissors.start()
        RockPaperScissors.play(pid)
        play()

      "3" ->
        {:ok, pid} = Wordle.start()
        RockPaperScissors.play(pid)
        play()

      "stop" ->
        IO.puts("Thanks for playing")

      "score" ->
        ScoreTracker.current_score(__MODULE__)

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
