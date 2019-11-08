defmodule Mah.Game do
  @moduledoc """
  Interface module to interact with games.
  """

  alias Mah.GameStore
  alias Mah.Mahjong.Game

  defdelegate alive?(game_id), to: Mah.GameStore

  def startable?(game_id) do
    with {:ok, game} <- GameStore.get(game_id), do: Game.startable?(game)
  end

  def participated?(game_id, player_id) do
    with {:ok, game} <- GameStore.get(game_id), do: Game.participated?(game, player_id)
  end

  def game(game_id) do
    with {:ok, game} <- GameStore.get(game_id), do: game
  end

  def players(game_id) do
    with {:ok, game} <- GameStore.get(game_id), do: Game.players(game)
  end

  def tsumoban(game_id) do
    with {:ok, game} <- GameStore.get(game_id), do: Game.tsumoban(game)
  end

  def tsumohai(game_id) do
    with {:ok, game} <- GameStore.get(game_id), do: Game.tsumohai(game)
  end

  def masked_for(game_id, player_id) do
    with {:ok, game} <- GameStore.get(game_id), do: Game.masked_for(game, player_id)
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

  defdelegate hands(game_id), to: Mah.Game.Server
  defdelegate start_game(game_id), to: Mah.Game.Server
  defdelegate dahai(game_id, player_id, hai), to: Mah.Game.Server
  defdelegate next_tsumo(game_id), to: Mah.Game.Server
  defdelegate state(game_id), to: Mah.Game.Server
end
