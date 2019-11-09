defmodule Mah.GameStore do
  use GenServer

  def start(game_id, game) do
    Horde.Supervisor.start_child(Mah.GameStoreSupervisor, {__MODULE__, [game_id, game]})
  end

  @impl true
  def start_link([game_id, game]) do
    GenServer.start_link(__MODULE__, game, name: via_tuple(game_id))
  end

  def get(game_id, fun) do
    GenServer.call(via_tuple(game_id), {:get, fun})
  end

  def update(game_id, fun) do
    GenServer.call(via_tuple(game_id), {:update, fun})
  end

  def stop(game_id) do
    Horde.Supervisor.terminate_child(Mah.GameStoreSupervisor, pid(game_id))
  end

  def alive?(game_id) do
    pid(game_id) |> is_pid()
  end

  @impl true
  def init(game) do
    {:ok, game}
  end

  @impl true
  def handle_call({:update, fun}, _from, game) do
    case fun.(game) do
      {:ok, game} ->
        {:reply, :ok, game}

      {:ok, game, reply} ->
        {:reply, reply, game}

      other ->
        {:reply, other, game}
    end
  end

  def handle_call({:get, fun}, _from, game) do
    {:reply, fun.(game), game}
  end

  defp pid(game_id) do
    case Horde.Registry.lookup(via_tuple(game_id)) do
      [{pid, _}] -> pid
      _else -> nil
    end
  end

  defp via_tuple(id) do
    {:via, Horde.Registry, {Mah.GameStoreRegistry, id}}
  end
end
