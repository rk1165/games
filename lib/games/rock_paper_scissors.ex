defmodule Games.RockPaperScissors do
  use GenServer

  @moduledoc """
  Rock, Paper, Scissors game
  """
  alias Games.ScoreTracker

  def start_link(_init) do
    GenServer.start_link(__MODULE__, [], name: :rock_paper_scissors)
  end

  def current_score(pid) do
    GenServer.call(pid, :current_score)
  end

  def play(pid) do
    ai_choice = Enum.random(["rock", "paper", "scissors"])
    player_choice = IO.gets("Choose rock, paper, or scissors: ") |> String.trim()
    GenServer.call(pid, {:play, ai_choice, player_choice})
  end

  def beats?(player_choice, ai_choice) do
    wins = [{"rock", "scissors"}, {"paper", "rock"}, {"scissors", "paper"}]

    {result, score} =
      cond do
        {player_choice, ai_choice} in wins ->
          ScoreTracker.add_points(:score_tracker, :rock_paper_scissors, 10)

          {IO.ANSI.green_background() <>
             "You win! #{player_choice} beats #{ai_choice}." <> IO.ANSI.reset(), 10}

        {ai_choice, player_choice} in wins ->
          {IO.ANSI.red_background() <>
             "You lose! #{ai_choice} beats #{player_choice}" <> IO.ANSI.reset(), 0}

        ai_choice == player_choice ->
          {IO.ANSI.yellow_background() <> "It's a tie" <> IO.ANSI.reset(), 0}

        true ->
          {IO.ANSI.red_background() <> "That looks wrong. Please try again" <> IO.ANSI.reset(), 0}
      end

    IO.puts(result)
    score
  end

  def init(_init_args) do
    {:ok, 0}
  end

  def handle_call(:current_score, _from, score) do
    {:reply, score, score}
  end

  def handle_call({:play, ai_choice, player_choice}, _from, score) do
    updated_score = score + beats?(player_choice, ai_choice)
    {:reply, updated_score, updated_score}
  end
end
