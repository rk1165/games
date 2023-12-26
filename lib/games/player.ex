defmodule Games.Player do
  @enforce_keys :id
  defstruct [:id, scores: %{:rps => 0, :gg => 0, :wordle => 0}]
end
