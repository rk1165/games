defmodule Games.GuessingGame do
  @moduledoc """
  Guess the number game
  """
  @spec play :: :ok
  def play() do
    guess = IO.gets("Guess a number between 1 and 10: ") |> String.trim() |> String.to_integer()
    answer = Enum.random(1..10)

    if guess == answer do
      IO.puts("You win!")
    else
      IO.puts("Incorrect!")
      play_helper(answer, 5)
    end
  end

  @spec play_helper(String.t(), integer()) :: :ok
  def play_helper(answer, attempts) do
    guess = IO.gets("Enter your guess: ") |> String.trim() |> String.to_integer()

    cond do
      guess == answer ->
        IO.puts("Correct!")

      attempts == 0 ->
        IO.puts("You lose! the answer was #{answer}")

      attempts > 0 and guess < answer ->
        IO.puts("Too Low!")
        play_helper(answer, attempts - 1)

      attempts > 0 and guess > answer ->
        IO.puts("Too High!")
        play_helper(answer, attempts - 1)
    end
  end
end
