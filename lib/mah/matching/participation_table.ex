defmodule Mah.Matching.ParticipationTable do
  use Agent

  @name {:global, __MODULE__}

  def start_link(_) do
    Agent.start_link(fn -> %{} end, name: @name)
  end

  def add(player_id, game_id) do
    case get(player_id) do
      nil -> Agent.update(@name, &Map.put(&1, player_id, game_id))
      ^game_id -> :ok
      _other -> :error
    end
  end

  def get(player_id) do
    Agent.get(@name, &Map.get(&1, player_id))
  end
end
