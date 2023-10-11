defmodule Games.RockPaperScissors do
  @moduledoc """
  Rock, Paper, Scissors game
  """
  alias Games.GameServer

  @spec play(String.t()) :: {:ok | :notok, String.t()}
  def play(id) do
    ai_choice = Enum.random(["rock", "paper", "scissors"])
    player_choice = IO.gets("Choose rock, paper, or scissors: ") |> String.trim()
    beats?(id, player_choice, ai_choice)
  end

  @spec beats?(String.t(), String.t(), String.t()) :: {:ok | :notok | :error, String.t()}
  def beats?(id, player_choice, ai_choice) do
    wins = [{"rock", "scissors"}, {"paper", "rock"}, {"scissors", "paper"}]

    cond do
      {player_choice, ai_choice} in wins ->
        GameServer.add_points(:game_server, id, :rps, 10)

        {:ok,
         IO.ANSI.green_background() <>
           "You win! #{player_choice} beats #{ai_choice}." <> IO.ANSI.reset()}

      {ai_choice, player_choice} in wins ->
        {:notok,
         IO.ANSI.red_background() <>
           "You lose! #{ai_choice} beats #{player_choice}" <> IO.ANSI.reset()}

      ai_choice == player_choice ->
        {:ok, IO.ANSI.yellow_background() <> "It's a tie" <> IO.ANSI.reset()}

      true ->
        {:error,
         IO.ANSI.red_background() <> "That looks wrong. Please try again" <> IO.ANSI.reset()}
    end
  end
end
