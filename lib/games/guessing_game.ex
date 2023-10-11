defmodule Games.GuessingGame do
  @moduledoc """
  Guess the number game
  """
  alias Games.GameServer

  @spec play(String.t()) :: {:ok | :notok, String.t()}
  def play(id) do
    play_helper(id, Enum.random(1..10), 5)
  end

  @spec play_helper(String.t(), String.t(), integer()) :: {:ok | :notok, String.t()}
  defp play_helper(id, answer, attempts) do
    guess =
      IO.gets(IO.ANSI.reset() <> "Guess a number between 1 and 10: ")
      |> String.trim()
      |> String.to_integer()

    cond do
      guess == answer ->
        GameServer.add_points(:game_server, id, :gg, 5)
        {:ok, IO.ANSI.green_background() <> "Correct! You win!!!" <> IO.ANSI.reset()}

      attempts == 0 ->
        {:notok, IO.ANSI.green_background() <> "Correct! You win!!!" <> IO.ANSI.reset()}

      attempts > 0 and guess < answer ->
        IO.puts(IO.ANSI.cyan_background() <> "Too Low!" <> IO.ANSI.reset())
        play_helper(id, answer, attempts - 1)

      attempts > 0 and guess > answer ->
        IO.puts(IO.ANSI.magenta_background() <> "Too High!" <> IO.ANSI.reset())
        play_helper(id, answer, attempts - 1)
    end
  end
end
