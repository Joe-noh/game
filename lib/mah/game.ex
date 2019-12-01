defmodule Mah.Game do
  @moduledoc """
  Interface module to interact with games.
  """

  alias Mah.GameStore
  alias Mah.Mahjong.Game

  defdelegate alive?(game_id), to: Mah.GameStore

  def masked_for(game_id, player_id) do
    GameStore.get(game_id, &Game.masked_for(&1, player_id))
  end

  def startable?(game_id) do
    GameStore.get(game_id, &Game.startable?(&1))
  end

  def participated?(game_id, player_id) do
    GameStore.get(game_id, &Game.participated?(&1, player_id))
  end

  def players(game_id) do
    GameStore.get(game_id, &Game.players(&1))
  end

  def tsumoban(game_id) do
    GameStore.get(game_id, &Game.tsumoban(&1))
  end

  def tsumohai(game_id) do
    GameStore.get(game_id, &Game.tsumohai(&1))
  end

  def masked_for(game_id, player_id) do
    GameStore.get(game_id, &Game.masked_for(&1, player_id))
  end

  def add_player(game_id, player_id) do
    GameStore.update(game_id, &Game.add_player(&1, player_id))
  end

  def ready_player(game_id, player_id) do
    GameStore.update(game_id, &Game.ready_player(&1, player_id))
  end

  def start(game_id) do
    GameStore.update(game_id, &Game.start(&1))
  end

  def tsumo(game_id) do
    GameStore.update(game_id, &Game.tsumo(&1))
  end
end
