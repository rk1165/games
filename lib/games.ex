defmodule Games do
  @moduledoc """
  Documentation for `Games`.
  """
  alias Games.GameServer
  alias Games.Wordle
  alias Games.RockPaperScissors
  alias Games.GuessingGame

  @spec main(any) :: :ok
  def main(_args) do
    id = register()
    play(id)
  end

  @spec play(String.t()) :: :ok
  def play(id) do
    # what if the id exists
    choice = prompt()

    case choice do
      "1" ->
        game = Task.async(fn -> GuessingGame.play(id) end)
        {_status, message} = Task.await(game, 3 * 60 * 1000)
        IO.puts(message)
        play(id)

      "2" ->
        game = Task.async(fn -> RockPaperScissors.play(id) end)
        {_status, message} = Task.await(game, 1 * 60 * 1000)
        IO.puts(message)
        play(id)

      "3" ->
        game = Task.async(fn -> Wordle.play(id) end)
        {_status, message} = Task.await(game, :infinity)
        IO.puts(message)
        play(id)

      "stop" ->
        # save player in DB??
        IO.puts("Thanks for playing")

      "score" ->
        IO.puts("==================================================")
        GameServer.current_score(:game_server, id) |> IO.inspect()
        IO.puts("==================================================")
        play(id)

      _ ->
        IO.puts("We didn't understand that. Would you like to try again?")
        play(id)
    end
  end

  def register() do
    IO.puts("Please register yourself before playing a game.")

    # handle check if ID is already existing
    id =
      IO.gets("""
      \nEnter a unique id for yourself
      """)
      |> String.trim()

    GameServer.register(:game_server, id)

    IO.puts("You have registered successfully!!!")
    id
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
