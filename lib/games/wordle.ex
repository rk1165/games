defmodule Games.Wordle do
  @moduledoc """
  Play wordle on command line
  """

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

  @spec play :: :ok
  def play() do
    answer =
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

    play_helper(6, answer)
  end

  @spec play_helper(integer(), String.t()) :: :ok
  def play_helper(attempts, answer) do
    guess = IO.gets(IO.ANSI.reset() <> "Enter a five letter word: ") |> String.trim()
    status = feedback(answer, guess)

    guess_list = String.split(guess, "", trim: true)

    guess_in_color =
      Enum.map(
        Enum.zip(status, guess_list),
        fn {val, guess_char} ->
          case val do
            :green -> IO.ANSI.green() <> String.upcase(guess_char)
            :yellow -> IO.ANSI.yellow() <> String.upcase(guess_char)
            :grey -> IO.ANSI.light_black() <> String.upcase(guess_char)
          end
        end
      )

    IO.puts(guess_in_color)

    cond do
      Enum.all?(status, fn elem -> elem == :green end) ->
        IO.puts(IO.ANSI.reset() <> "You won!!!")

      attempts == 0 ->
        IO.puts(IO.ANSI.red() <> "You lose! the answer was #{answer}")

      true ->
        IO.ANSI.reset()
        play_helper(attempts - 1, answer)
    end
  end
end
