defmodule Games.GuessingGame do
  @moduledoc """
  Guess the number game
  """
  @spec play :: :ok
  def play() do
    answer = Enum.random(1..10)
    play_helper(answer, 5)
  end

  @spec play_helper(String.t(), integer()) :: :ok
  def play_helper(answer, attempts) do
    guess =
      IO.gets(IO.ANSI.reset() <> "Guess a number between 1 and 10: ")
      |> String.trim()
      |> String.to_integer()

    cond do
      guess == answer ->
        IO.puts(IO.ANSI.green() <> "Correct! You win!!!")

      attempts == 0 ->
        IO.puts(IO.ANSI.red() <> "You lose! the answer was #{answer}")

      attempts > 0 and guess < answer ->
        IO.puts(IO.ANSI.cyan() <> "Too Low!")
        play_helper(answer, attempts - 1)

      attempts > 0 and guess > answer ->
        IO.puts(IO.ANSI.magenta() <> "Too High!")
        play_helper(answer, attempts - 1)
    end
  end
end
