defmodule Games.ScoreTracker do
  use GenServer

  def start_link(_init) do
    GenServer.start_link(__MODULE__, [], name: :score_tracker)
  end

  def add_points(pid, game, points) do
    GenServer.cast(pid, {:add_points, game, points})
  end

  def current_score(pid) do
    GenServer.call(pid, :get_score)
  end

  def init(_init_arg) do
    current_state = %{:rock_paper_scissors => 0, :guessing_game => 0, :wordle => 0}
    {:ok, current_state}
  end

  def handle_cast({:add_points, game, points}, state) do
    updated_state = Map.update!(state, game, fn curr -> curr + points end)
    {:noreply, updated_state}
  end

  def handle_call(:get_score, _from, state) do
    {:reply, state, state}
  end
end
