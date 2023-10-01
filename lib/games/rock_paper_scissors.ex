defmodule Games.RockPaperScissors do
  def play() do
    player_choice = IO.gets("Choose rock, paper, or scissors: ") |> String.trim()
    ai_choice = Enum.random(["rock", "paper", "scissors"])

    case {player_choice, ai_choice} do
      {"rock", "scissors"} -> "You win! rock beats scissors."
      {"paper", "rock"} -> "You win! paper beats rock."
      {"scissors", "paper"} -> "You win! scissors beats paper."
      {player_choice, player_choice} -> "It's a tie!"
      _ -> "You lose! #{ai_choice} beats #{player_choice}"
    end
  end
end
