defmodule Games.GuessingGame do
  use GenServer

  @moduledoc """
  Guess the number game
  """
  alias Games.ScoreTracker

  def start_link(_init) do
    GenServer.start_link(__MODULE__, [], name: :guessing_game)
  end

  def current_score(pid) do
    GenServer.call(pid, :current_score)
  end

  def play(pid) do
    # waiting 15s for answer
    GenServer.call(pid, :guess, :infinity)
  end

  @spec play_helper(String.t(), integer()) :: integer()
  defp play_helper(answer, attempts) do
    guess =
      IO.gets(IO.ANSI.reset() <> "Guess a number between 1 and 10: ")
      |> String.trim()
      |> String.to_integer()

    cond do
      guess == answer ->
        IO.puts(IO.ANSI.green_background() <> "Correct! You win!!!" <> IO.ANSI.reset())
        ScoreTracker.add_points(:score_tracker, :guessing_game, 5)
        5

      attempts == 0 ->
        IO.puts(
          IO.ANSI.red_background() <> "You lose! the answer was #{answer}" <> IO.ANSI.reset()
        )

        0

      attempts > 0 and guess < answer ->
        IO.puts(IO.ANSI.cyan_background() <> "Too Low!" <> IO.ANSI.reset())
        play_helper(answer, attempts - 1)

      attempts > 0 and guess > answer ->
        IO.puts(IO.ANSI.magenta_background() <> "Too High!" <> IO.ANSI.reset())
        play_helper(answer, attempts - 1)
    end
  end

  def init(_init_args) do
    {:ok, 0}
  end

  def handle_call(:current_score, _from, score) do
    {:reply, score, score}
  end

  def handle_call(:guess, _from, score) do
    updated_score = score + play_helper(Enum.random(1..10), 5)
    {:reply, updated_score, updated_score}
  end
end
