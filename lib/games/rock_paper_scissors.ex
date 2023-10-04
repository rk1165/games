defmodule Games.RockPaperScissors do
  @moduledoc """
  Rock, Paper, Scissors game
  """

  @spec play :: :ok
  def play() do
    player_choice = IO.gets("Choose rock, paper, or scissors: ") |> String.trim()
    ai_choice = Enum.random(["rock", "paper", "scissors"])
    wins = [{"rock", "scissors"}, {"paper", "rock"}, {"scissors", "paper"}]

    result =
      cond do
        {player_choice, ai_choice} in wins ->
          IO.ANSI.green() <> "You win! #{player_choice} beats #{ai_choice}."

        {ai_choice, player_choice} in wins ->
          IO.ANSI.red() <> "You lose! #{ai_choice} beats #{player_choice}"

        true ->
          IO.ANSI.yellow() <> "It's a tie"
      end

    IO.puts(result)
  end
end
