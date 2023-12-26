defmodule Games.RockPaperScissors do
  @moduledoc """
  Rock, Paper, Scissors game
  """
  require Logger
  alias Games.GameServer
  alias Games.HttpServer

  @spec play(String.t(), port()) :: :ok
  def play(id, client_socket) do
    Logger.info("#{id} playing Rock, Paper, Scissors")
    ai_choice = Enum.random(["rock", "paper", "scissors"])
    HttpServer.write_response("Choose rock, paper, or scissors: ", client_socket)
    player_choice = HttpServer.read_request(client_socket) |> String.trim()
    status = beats?(id, player_choice, ai_choice)
    HttpServer.write_response(status, client_socket)
  end

  @spec beats?(String.t(), String.t(), String.t()) :: String.t()
  def beats?(id, player_choice, ai_choice) do
    wins = [{"rock", "scissors"}, {"paper", "rock"}, {"scissors", "paper"}]

    cond do
      {player_choice, ai_choice} in wins ->

        GameServer.add_points(:game_server, id, :rps, 10)
        Logger.info("#{id} won Rock, Paper, Scissors")

        IO.ANSI.green_background() <>
          "You win! #{player_choice} beats #{ai_choice}." <> IO.ANSI.reset()

      {ai_choice, player_choice} in wins ->
        Logger.info("#{id} lost Rock, Paper, Scissors")

        IO.ANSI.red_background() <>
          "You lose! #{ai_choice} beats #{player_choice}" <> IO.ANSI.reset()

      ai_choice == player_choice ->
        IO.ANSI.yellow_background() <> "It's a tie" <> IO.ANSI.reset()

      true ->
        IO.ANSI.red_background() <> "That looks wrong. Please try again" <> IO.ANSI.reset()
    end
  end
end
