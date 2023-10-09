defmodule Games.Application do
  use Application

  def start(_start_type, _start_args) do
    children = [
      {Games.GuessingGame, []},
      {Games.RockPaperScissors, []},
      {Games.Wordle, []},
      {Games.ScoreTracker, []}
    ]

    opts = [strategy: :one_for_one, name: Games.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
