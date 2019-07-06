defmodule Mj.Game.Server do
  use GenServer
  require Logger

  alias Mj.Game.State

  def child_spec(id) do
    %{id: id, start: {__MODULE__, :start_link, [id]}}
  end

  # API

  def start_link(id) do
    Logger.info("Starting Game.Server (id: #{id})")
    GenServer.start_link(__MODULE__, id, name: via_tuple(id))
  end

  def add_player(id, player_id) do
    GenServer.call(via_tuple(id), {:add_player, player_id})
  end

  # Callbacks

  def init(id) do
    Process.flag(:trap_exit, true)
    {:ok, State.new(id)}
  end

  def handle_call({:add_player, _}, _from, state = %{players: players}) when length(players) >= 4 do
    {:reply, {:error, :full}, state}
  end

  def handle_call({:add_player, player_id}, _from, state = %{players: players}) do
    if player_id in players do
      {:reply, {:error, :already_joined}, state}
    else
      {:reply, :ok, %State{state | players: [player_id | players]}}
    end
  end

  def terminate(_reason, state = %{id: id}) do
    Logger.info("id: #{id} terminating. state: #{inspect(state)}")
    :ok
  end

  defp via_tuple(id) do
    {:via, Horde.Registry, {Mj.GameRegistry, id}}
  end
end
