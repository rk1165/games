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
          IO.ANSI.green_background() <> "You win! #{player_choice} beats #{ai_choice}." <> IO.ANSI.reset()

        {ai_choice, player_choice} in wins ->
          IO.ANSI.red_background() <> "You lose! #{ai_choice} beats #{player_choice}" <> IO.ANSI.reset()

        ai_choice == player_choice ->
          IO.ANSI.yellow_background() <> "It's a tie" <> IO.ANSI.reset()

        true ->
          IO.ANSI.red_background() <> "That looks wrong. Please try again" <> IO.ANSI.reset()
      end

    IO.puts(result)
  end
end
