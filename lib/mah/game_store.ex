defmodule Mah.GameStore do
  use Agent

  def start(game_id, game) do
    Horde.Supervisor.start_child(Mah.GameStoreSupervisor, {__MODULE__, [game_id, game]})
  end

  def start_link([game_id, game]) do
    Agent.start_link(fn -> game end, name: via_tuple(game_id))
  end

  def get(game_id) do
    if_alive(game_id, fn _pid ->
      Agent.get(via_tuple(game_id), fn game -> game end)
    end)
  end

  def put(game_id, game) do
    if_alive(game_id, fn _pid ->
      Agent.update(via_tuple(game_id), fn _ -> game end)
    end)
  end

  def update(game_id, fun) do
    if_alive(game_id, fn _pid ->
      Agent.update(via_tuple(game_id), fun)
    end)
  end

  def stop(game_id) do
    if_alive(game_id, fn pid ->
      Horde.Supervisor.terminate_child(Mah.GameStoreSupervisor, pid)
    end)
  end

  def pid(game_id) do
    case Horde.Registry.lookup(via_tuple(game_id)) do
      [{pid, _}] -> pid
      _else -> nil
    end
  end

  defp if_alive(game_id, fun) do
    case pid(game_id) do
      nil -> {:error, :not_found}
      pid -> fun.(pid)
    end
  end

  defp via_tuple(id) do
    {:via, Horde.Registry, {Mah.GameStoreRegistry, id}}
  end
end
