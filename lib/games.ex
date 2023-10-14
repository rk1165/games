defmodule Games do
  @moduledoc """
  Documentation for `Games`.
  """
  require Logger
  alias Games.GameServer
  alias Games.Wordle
  alias Games.RockPaperScissors
  alias Games.GuessingGame
  alias Games.HttpServer

  @spec start(String.t(), port()) :: String.t()
  def start(_request, client_socket) do
    id = register(client_socket)
    play(id, client_socket)
  end

  @spec play(String.t(), port()) :: String.t()
  def play(id, client_socket) do
    # what if the id exists
    choice = menu(client_socket)

    case choice do
      "1" ->
        game = Task.async(fn -> GuessingGame.play(id, client_socket) end)
        Task.await(game, 3 * 60 * 1000)
        play(id, client_socket)

      "2" ->
        game = Task.async(fn -> RockPaperScissors.play(id, client_socket) end)
        Task.await(game, 1 * 60 * 1000)
        play(id, client_socket)

      "3" ->
        game = Task.async(fn -> Wordle.play(id, client_socket) end)
        Task.await(game, :infinity)
        play(id, client_socket)

      "stop" ->
        # save player in DB??
        Logger.info("#{id} stopped playing")
        "Thanks for playing"

      "score" ->
        HttpServer.write_response("\n", client_socket)
        HttpServer.write_response("========================================\n", client_socket)

        score =
          GameServer.current_score(:game_server, id)
          |> form_score()

        Logger.info("#{id}'s score across all games: \n #{score}")
        HttpServer.write_response(score, client_socket)

        HttpServer.write_response("========================================\n", client_socket)
        play(id, client_socket)

      _ ->
        Logger.error("We didn't understand that. Would you like to try again?")
        play(id, client_socket)
    end
  end

  def register(client_socket) do
    HttpServer.write_response(
      """
      Please register yourself before playing a game.
      Enter a unique id for yourself:
      """,
      client_socket
    )

    id = HttpServer.read_request(client_socket) |> String.trim()

    # handle check if ID is already existing - this however is already taken care of if the server is running
    GameServer.register(:game_server, id)
    HttpServer.write_response("You have registered successfully!!!\n\n", client_socket)
    id
  end

  def menu(client_socket) do
    prompt =
      """
      \nWhat game would you like to play?
      1. Guessing Game
      2. Rock Paper Scissors
      3. Wordle

      enter "stop" to exit
      enter "score" to view your current score
      """

    HttpServer.write_response(prompt, client_socket)
    HttpServer.read_request(client_socket) |> String.trim()
  end

  def form_score(score_map) do
    Enum.reduce(Map.keys(score_map), "", fn key, acc ->
      game_name =
        case key do
          :gg -> "Guessing Game"
          :rps -> "Rock, Paper, Scissors"
          :wordle -> "Wordle"
        end

      acc <> "#{game_name} : #{Map.get(score_map, key)} \n"
    end)
  end
end
