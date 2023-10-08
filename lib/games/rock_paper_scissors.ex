defmodule Games.RockPaperScissors do
  use GenServer

  @moduledoc """
  Rock, Paper, Scissors game
  """

  def start() do
    GenServer.start_link(__MODULE__, [], name: :rock_paper_scissors)
  end

  def current_score(pid) do
    GenServer.call(pid, :current_score)
  end

  def play(pid) do
    # waiting 15s for answer
    GenServer.call(pid, :play, 15000)
  end

  @spec rps :: integer()
  def rps() do
    player_choice = IO.gets("Choose rock, paper, or scissors: ") |> String.trim()
    ai_choice = Enum.random(["rock", "paper", "scissors"])
    wins = [{"rock", "scissors"}, {"paper", "rock"}, {"scissors", "paper"}]

    {result, score} =
      cond do
        {player_choice, ai_choice} in wins ->
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

  def handle_call(:play, _from, score) do
    updated_score = score + rps()
    {:reply, updated_score, updated_score}
  end
end
