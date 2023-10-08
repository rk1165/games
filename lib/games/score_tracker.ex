defmodule Games.ScoreTracker do
  use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, [], name: :score_tracker)
  end

  def add_points(pid, points) do
    GenServer.cast(pid, {:add_points, points})
  end

  def current_score(pid) do
    GenServer.call(pid, :get_score)
  end

  def init(_init_arg) do
    {:ok, 0}
  end

  def handle_cast({:add_points, points}, state) do
    {:noreply, state + points}
  end

  def handle_call(:get_score, _from, state) do
    {:reply, state, state}
  end
end
