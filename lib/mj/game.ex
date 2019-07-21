defmodule Mj.Game do
  @moduledoc """
  Interface module to interact with games.
  """

  def spawn_new_game do
    game_id = UUID.uuid4()
    {:ok, pid} = Horde.Supervisor.start_child(Mj.GameSupervisor, {Mj.Game.Server, game_id})

    {:ok, pid, game_id}
  end

  defdelegate add_player(game_id, player_id), to: Mj.Game.Server
  defdelegate start_game(game_id), to: Mj.Game.Server
end
