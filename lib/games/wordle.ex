defmodule Games.Wordle do
  @alphabet "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

  @moduledoc """
  Play wordle on command line
  """
  require Logger
  alias Games.GameServer
  alias Games.HttpServer

  @spec play(any(), port()) :: :ok
  def play(id, client_socket) do
    Logger.info("id #{id} playing Wordle")
    play_helper(id, client_socket, 6, generate_answer(), initialize_letters())
  end

  @spec play_helper(String.t(), port(), integer(), String.t(), map()) :: :ok
  def play_helper(id, client_socket, attempts, answer, letter_map) do
    HttpServer.write_response("Enter a five letter word: ", client_socket)
    guess = HttpServer.read_request(client_socket) |> String.trim()

    feedback_list = feedback(answer, guess)
    guess_list = String.split(guess, "", trim: true)

    {guess_in_color, updated_letter_map} =
      check_and_update_map(feedback_list, guess_list, letter_map)

    HttpServer.write_response(guess_in_color <> "\n", client_socket)
    HttpServer.write_response(render_letters(updated_letter_map) <> "\n", client_socket)

    cond do
      Enum.all?(feedback_list, fn elem -> elem == :green end) ->
        GameServer.add_points(:game_server, id, :wordle, 25)
        Logger.info("#{id} won Wordle")

        HttpServer.write_response(
          IO.ANSI.green_background() <> "You won!!!" <> IO.ANSI.reset() <> "\n",
          client_socket
        )

      attempts == 0 ->
        Logger.info("#{id} lost Wordle")

        HttpServer.write_response(
          "\n" <>
            IO.ANSI.red_background() <>
            "You lose! the answer was #{answer}" <> IO.ANSI.reset() <> "\n",
          client_socket
        )

      true ->
        play_helper(id, client_socket, attempts - 1, answer, updated_letter_map)
    end
  end

  @spec feedback(String.t(), String.t()) :: [atom()]
  def feedback(answer, guess) do
    answer_list = String.split(answer, "", trim: true)
    guess_list = String.split(guess, "", trim: true)
    answer_count = answer_list |> Enum.frequencies()

    {result, updated_answer_count} =
      Enum.reduce(
        Enum.zip(answer_list, guess_list),
        {[], answer_count},
        fn {answer_char, guess_char}, {list, answer_count} = _acc ->
          cond do
            answer_char == guess_char ->
              # add green to the list and reduce the answer char by 1
              {[:green | list], Map.update!(answer_count, answer_char, &(&1 - 1))}

            true ->
              # otherwise add grey to the list and don't update answer_count
              {[:grey | list], answer_count}
          end
        end
      )

    result = Enum.reverse(result)

    # to check if it's grey and needs to be updated to yellow
    {_, new_result, _} =
      Enum.reduce(
        guess_list,
        {0, result, updated_answer_count},
        fn guess, {index, result, updated_answer_count} = _acc ->
          cond do
            # if the value in result index is grey, check if answer has a key for guess and it's value > 0
            # because it would mean that even though our guess doesn't match the answer at that index
            # there is however guess present in answer. If we make it yellow
            # we should also reduce the answer_count of that guess_char
            Enum.at(result, index) == :grey and Map.has_key?(updated_answer_count, guess) and
                Map.get(updated_answer_count, guess) > 0 ->
              {index + 1, List.replace_at(result, index, :yellow),
               Map.update!(updated_answer_count, guess, &(&1 - 1))}

            true ->
              {index + 1, result, updated_answer_count}
          end
        end
      )

    new_result
  end

  @spec generate_answer() :: String.t()
  def generate_answer() do
    Enum.random([
      "toast",
      "tarts",
      "hello",
      "beats",
      "brain",
      "adieu",
      "chain",
      "crime",
      "cream",
      "every",
      "lunch",
      "maybe",
      "stuck",
      "slope",
      "faith"
    ])
  end

  @spec check_and_update_map(list(), [String.t()], map()) :: {String.t(), map()}
  def check_and_update_map(feedback_list, guess_list, letter_map) do
    Enum.reduce(
      Enum.zip(feedback_list, guess_list),
      {"", letter_map},
      fn {feedback, guess_char}, {result, letter_map} ->
        {result <> format_letter(guess_char, feedback),
         color_letter_in_map(letter_map, guess_char, feedback)}
      end
    )
  end

  @spec initialize_letters :: map()
  def initialize_letters() do
    @alphabet
    |> String.split("", trim: true)
    |> Enum.reduce(%{}, fn char, acc ->
      Map.put(acc, char, IO.ANSI.black_background() <> char <> IO.ANSI.reset())
    end)
  end

  @spec render_letters(map()) :: binary()
  def render_letters(letter_map) do
    @alphabet
    |> String.split("", trim: true)
    |> Enum.reduce("", fn letter, acc -> acc <> Map.get(letter_map, letter) end)
  end

  @spec color_letter_in_map(map, binary, :green | :grey | :yellow) :: map
  def color_letter_in_map(letter_map, letter, color) do
    %{letter_map | String.upcase(letter) => format_letter(letter, color)}
  end

  @spec format_letter(binary, :green | :grey | :yellow) :: binary
  def format_letter(letter, color) do
    upcase = String.upcase(letter)

    case color do
      :green ->
        IO.ANSI.green_background() <> upcase <> IO.ANSI.reset()

      :yellow ->
        IO.ANSI.yellow_background() <> upcase <> IO.ANSI.reset()

      :grey ->
        IO.ANSI.light_black_background() <> upcase <> IO.ANSI.reset()
    end
  end
end
