defmodule Games.GameServer do
  alias Games.Player
  use GenServer

  def start_link(_init) do
    GenServer.start_link(__MODULE__, [], name: :game_server)
  end

  def register(pid, id) do
    # how to check if the user is already registered
    GenServer.call(pid, {:register, id})
  end

  def add_points(pid, id, game, points) do
    GenServer.cast(pid, {:add_points, id, game, points})
  end

  def current_score(pid, id) do
    GenServer.call(pid, {:get_score, id})
  end

  def players(pid) do
    GenServer.call(pid, :players)
  end

  def player(pid, id) do
    GenServer.call(pid, {:get, id})
  end

  def init(_init_arg) do
    {:ok, %{}}
  end

  def handle_call({:register, id}, _from, state) do
    player = %Player{id: id}
    new_state = Map.put_new(state, id, player)
    {:reply, :ok, new_state}
  end

  def handle_call({:get_score, id}, _from, state) do
    scores = Map.get(state, id).scores
    {:reply, scores, state}
  end

  def handle_call(:players, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:get, id}, _from, state) do
    {:reply, Map.get(state, id), state}
  end

  def handle_cast({:add_points, id, game, points}, state) do
    IO.inspect(state, label: "previous_state")
    player = Map.get(state, id)
    scores = player.scores
    updated_score = Map.update!(scores, game, fn curr -> curr + points end)
    updated_player = %Player{player | scores: updated_score}
    updated_state = %{state | id => updated_player}
    IO.inspect(updated_state, label: "updated_state")
    {:noreply, updated_state}
  end
end
