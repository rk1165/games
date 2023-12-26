defmodule Games.GuessingGame do
  @moduledoc """
  Guess the number game
  """
  require Logger
  alias Games.GameServer
  alias Games.HttpServer

  @spec play(String.t(), port()) :: :ok
  def play(id, client_socket) do
    Logger.info("#{id} playing Guessing Game")
    play_helper(id, client_socket, Enum.random(1..10), 5)
  end

  @spec play_helper(String.t(), port(), String.t(), integer()) :: :ok
  defp play_helper(id, client_socket, answer, attempts) do
    HttpServer.write_response("Guess a number between 1 and 10: ", client_socket)
    guess = HttpServer.read_request(client_socket) |> String.trim() |> String.to_integer()

    cond do
      guess == answer ->
        GameServer.add_points(:game_server, id, :gg, 5)
        Logger.info("#{id} won Guessing Game")

        HttpServer.write_response(
          IO.ANSI.green_background() <> "Correct! You win!!!" <> IO.ANSI.reset() <> "\n",
          client_socket
        )

      attempts == 0 ->
        Logger.info("#{id} lost Guessing Game")

        HttpServer.write_response(
          IO.ANSI.red_background() <> "Sorry! You lost!!!" <> IO.ANSI.reset() <> "\n",
          client_socket
        )

      attempts > 0 and guess < answer ->
        HttpServer.write_response(
          IO.ANSI.cyan_background() <> "Too Low!" <> IO.ANSI.reset() <> "\n",
          client_socket
        )

        play_helper(id, client_socket, answer, attempts - 1)

      attempts > 0 and guess > answer ->
        HttpServer.write_response(
          IO.ANSI.magenta_background() <> "Too High!" <> IO.ANSI.reset() <> "\n",
          client_socket
        )

        play_helper(id, client_socket, answer, attempts - 1)
    end
  end
end
