defmodule Games.Wordle do
  use ExUnit.Case

  def feedback(answer, guess) do
    # result = [:grey, :grey, :grey, :grey, :grey]
    answer_list = String.split(answer, "", trim: true)
    guess_list = String.split(guess, "", trim: true)
    answer_count = word_to_char_count(answer)
    guess_count = word_to_char_count(guess)

    # IO.inspect(answer_count, label: "answer_count")
    # IO.inspect(guess_count, label: "guess_count")

    result =
      Enum.map(Enum.zip(answer_list, guess_list), fn {answer_char, guess_char} ->
        cond do
          answer_char == guess_char ->
            :green

          true ->
            :grey
        end
      end)

    {final_answer_count, _final_guess_count} =
      Enum.reduce(
        Enum.zip(answer_list, guess_list),
        {answer_count, guess_count},
        fn {answer_char, guess_char}, {answer_count, guess_count} = acc ->
          cond do
            answer_char == guess_char ->
              {Map.update!(answer_count, answer_char, &(&1 - 1)),
               Map.update!(guess_count, guess_char, &(&1 - 1))}

            true ->
              acc
          end
        end
      )

    # IO.inspect(final_answer_count, label: "final_answer_count")
    # IO.inspect(final_guess_count, label: "final_guess_count")
    # IO.inspect(result, label: "result")

    {_, new_result, _} =
      Enum.reduce(
        guess_list,
        {0, result, final_answer_count},
        fn guess, {index, list, final_answer_count} = _acc ->
          case Enum.at(list, index) do
            :grey ->
              cond do
                Map.has_key?(final_answer_count, guess) and Map.get(final_answer_count, guess) > 0 ->
                  # IO.inspect(guess, label: "guess")

                  {index + 1, List.replace_at(list, index, :yellow),
                   Map.update!(final_answer_count, guess, &(&1 - 1))}

                true ->
                  # IO.inspect(guess, label: "other guess")
                  {index + 1, list, final_answer_count}
              end

            _ ->
              {index + 1, list, final_answer_count}
          end
        end
      )

    # IO.puts(new_result)
    new_result
  end

  def word_to_char_count(word) do
    split_string = String.split(word, "", trim: true)

    Enum.reduce(split_string, %{}, fn char, map_accumulator ->
      Map.update(map_accumulator, char, 1, fn current -> current + 1 end)
    end)
  end

  def play() do
    answer = Enum.random(["toast", "tarts", "hello", "beats"])

    play_helper(6, answer)
  end

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
        IO.puts("You won!!!")

      attempts == 0 ->
        IO.puts(IO.ANSI.red() <> "You lose! the answer was #{answer}")

      true ->
        IO.ANSI.reset()
        play_helper(attempts - 1, answer)
    end
  end
end
