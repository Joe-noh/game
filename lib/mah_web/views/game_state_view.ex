defmodule MahWeb.GameStateView do
  @moduledoc """
  View functions for game state serialization. Used by `MahWeb.EventPusher`.
  """

  use MahWeb, :view

  alias Mah.Game.State

  def render("show.json", %{player: player, game: game = %State{}}) do
    %{
      id: game.id,
      players: game.players,
      honba: game.honba,
      round: game.round,
      tsumoban: game.tsumoban,
      tsumohai: tsumohai(player, game),
      tehai: Map.get(game.tehai, player),
      sutehai: game.sutehai
    }
  end

  defp tsumohai(player, %State{tsumoban: player, tsumohai: tsumohai}) do
    tsumohai
  end

  defp tsumohai(_, _) do
    nil
  end
end
