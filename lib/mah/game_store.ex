defmodule Mah.GameStore do
  use Agent

  def start(game_id, game) do
    Horde.Supervisor.start_child(Mah.GameStoreSupervisor, {__MODULE__, [game_id, game]})
  end

  def start_link([game_id, game]) do
    Agent.start_link(fn -> game end, name: via_tuple(game_id))
  end

  def get(game_id) do
    if_alive(game_id, &Agent.get(&1, fn game -> game end))
  end

  def put(game_id, game) do
    if_alive(game_id, &Agent.update(&1, fn _ -> game end))
  end

  def update(game_id, fun) do
    if_alive(game_id, &Agent.update(&1, fn game -> fun.(game) |> unwrap() end))
  end

  defp unwrap({:ok, result}), do: result
  defp unwrap(result), do: result

  def stop(game_id) do
    if_alive(game_id, &Horde.Supervisor.terminate_child(Mah.GameStoreSupervisor, &1))
  end

  def pid(game_id) do
    case Horde.Registry.lookup(via_tuple(game_id)) do
      [{pid, _}] -> pid
      _else -> nil
    end
  end

  def alive?(game_id) do
    pid(game_id) |> is_pid()
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
