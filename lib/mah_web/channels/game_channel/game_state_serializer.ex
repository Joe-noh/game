defmodule MahWeb.GameChannel.GameStateSerializer do
  def render(%{player: player, game: game}) do
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

  defp tsumohai(player, %{tsumoban: player, tsumohai: tsumohai}) do
    tsumohai
  end

  defp tsumohai(_, _) do
    nil
  end
end
