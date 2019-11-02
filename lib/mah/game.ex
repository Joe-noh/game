defmodule Mah.Game do
  @moduledoc """
  Interface module to interact with games.
  """

  def spawn(%{id: id}, first_player) do
    {:ok, game} = %Mah.Mahjong.Game{} |> Mah.Mahjong.Game.add_player(first_player)
    {:ok, _pid} = Mah.GameStore.start(id, game)
  end

  def spawn_new_game do
    game_id = UUID.uuid4()
    {:ok, pid} = Horde.Supervisor.start_child(Mah.GameSupervisor, {Mah.Game.Server, game_id})

    {:ok, pid, game_id}
  end

  defdelegate players(game_id), to: Mah.Game.Server
  defdelegate hands(game_id), to: Mah.Game.Server
  defdelegate alive?(game_id), to: Mah.Game.Server
  defdelegate add_player(game_id, player_id), to: Mah.Game.Server
  defdelegate player_ready(game_id, player_id), to: Mah.Game.Server
  defdelegate start_game(game_id), to: Mah.Game.Server
  defdelegate startable_with?(game_id, player_ids), to: Mah.Game.Server
  defdelegate dahai(game_id, player_id, hai), to: Mah.Game.Server
  defdelegate next_tsumo(game_id), to: Mah.Game.Server
  defdelegate state(game_id), to: Mah.Game.Server
end
