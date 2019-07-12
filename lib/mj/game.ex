defmodule Mj.Game do
  @moduledoc """
  Interface module to interact with games.
  """

  def spawn_new_game do
    game_id = UUID.uuid4()
    {:ok, pid} = Horde.Supervisor.start_child(Mj.GameSupervisor, {Mj.Game.Server, game_id})

    {:ok, pid, game_id}
  end

  def add_player(game_id, player_id) do
    Mj.Game.Server.add_player(game_id, player_id)
  end

  def start_game(game_id) do
    Mj.Game.Server.start_game(game_id)
  end
end
