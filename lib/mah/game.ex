defmodule Mah.Game do
  @moduledoc """
  Interface module to interact with games.
  """

  alias Mah.GameStore
  alias Mah.Mahjong.Game

  defdelegate alive?(game_id), to: Mah.GameStore

  def startable?(game_id) do
    GameStore.get(game_id) |> Game.startable?()
  end

  def participated?(game_id, player_id) do
    GameStore.get(game_id) |> Game.participated?(player_id)
  end

  def game(game_id) do
    GameStore.get(game_id)
  end

  def players(game_id) do
    GameStore.get(game_id) |> Game.players()
  end

  def tsumoban(game_id) do
    GameStore.get(game_id) |> Game.tsumoban()
  end

  def tsumohai(game_id) do
    GameStore.get(game_id) |> Game.tsumohai()
  end

  def masked_for(game_id, player_id) do
    GameStore.get(game_id) |> Game.masked_for(player_id)
  end

  def start(game_id) do
    GameStore.update(game_id, &Game.haipai(&1))
  end

  def tsumo(game_id) do
    GameStore.update(game_id, &Game.tsumo(&1))
  end

  defdelegate hands(game_id), to: Mah.Game.Server
  defdelegate add_player(game_id, player_id), to: Mah.Game.Server
  defdelegate player_ready(game_id, player_id), to: Mah.Game.Server
  defdelegate start_game(game_id), to: Mah.Game.Server
  defdelegate dahai(game_id, player_id, hai), to: Mah.Game.Server
  defdelegate next_tsumo(game_id), to: Mah.Game.Server
  defdelegate state(game_id), to: Mah.Game.Server
end
