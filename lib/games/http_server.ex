defmodule Games.HttpServer do
  require Logger

  def main(_request) do
    start(9000)
  end

  @spec start(integer()) :: :ok
  def start(port) when is_integer(port) and port > 1023 do
    options = [:binary, packet: :raw, active: false, reuseaddr: true]
    {:ok, listen_socket} = :gen_tcp.listen(port, options)

    Logger.info("🎧 Listening for connection requests on port #{port}...")

    accept_loop(listen_socket)
  end

  @spec accept_loop(port()) :: :ok
  def accept_loop(listen_socket) do
    Logger.info("⌛️ Waiting to accept a client connection...")
    {:ok, client_socket} = :gen_tcp.accept(listen_socket)
    Logger.info("⚡️ Connection accepted!")

    pid = spawn(fn -> serve(client_socket) end)
    :ok = :gen_tcp.controlling_process(client_socket, pid)

    accept_loop(listen_socket)
  end

  @spec serve(port()) :: :ok
  def serve(client_socket) do
    write_response(
      """

      Hello there. I hope you are doing well.
      I have created some simple games for you to play.
      Hopefully you will enjoy them.
      Please follow the instructions to play.

      What would you like to do?
      1. play
      2. quit

      """,
      client_socket
    )

    request = read_request(client_socket) |> String.trim()

    case request do
      "1" ->
        handle_request(request, client_socket)

      "2" ->
        write_response(
          """
          Thanks for connecting.
          Have a nice day.
          """,
          client_socket
        )

        close_client_connection(client_socket)

      _ ->
        write_response(
          """
          Sorry, I didn't understand that.
          Would you like to try again?
          """,
          client_socket
        )

        serve(client_socket)
    end
  end

  @spec read_request(port()) :: String.t()
  def read_request(client_socket) do
    {:ok, request} = :gen_tcp.recv(client_socket, 0)
    Logger.info("➡️  Received request: #{String.trim(request)}")

    request
  end

  @spec handle_request(String.t(), port()) :: :ok
  def handle_request(request, client_socket) do
    response = Games.start(request, client_socket)
    write_response(response <> "\n", client_socket)
    close_client_connection(client_socket)
  end

  @spec write_response(String.t(), port()) :: :ok
  def write_response(response, client_socket) do
    :ok = :gen_tcp.send(client_socket, response)
  end

  @spec close_client_connection(port()) :: :ok
  def close_client_connection(client_socket) do
    :gen_tcp.close(client_socket)
  end
end
