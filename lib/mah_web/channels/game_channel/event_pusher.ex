defmodule MahWeb.GameChannel.EventPusher do
  @moduledoc """
  This provides functions to push game events from server to clients.
  """

  @spec game_start(payload :: map()) :: :ok | no_return()
  def game_start(game_id) do
    Mah.Game.players(game_id)
    |> Enum.each(fn player_id ->
      push(player_id, "game:start", Mah.Game.masked_for(game_id, player_id))
    end)
  end

  @spec tsumo(payload :: map()) :: :ok | no_return()
  def tsumo(game_id) do
    tsumoban = Mah.Game.tsumoban(game_id)
    tsumohai = Mah.Game.tsumohai(game_id)

    Mah.Game.players(game_id)
    |> Enum.each(fn
      ^tsumoban -> push(tsumoban, "game:tsumo", %{tsumohai: tsumohai})
      other -> push(other, "game:tacha_tsumo", %{player: tsumoban})
    end)
  end

  def dahai(%{player: player, players: players, hai: hai, tsumogiri: tsumogiri}) do
    Enum.each(players, fn id ->
      push(id, "game:dahai", %{player: player, hai: hai, tsumogiri: tsumogiri})
    end)
  end

  @spec push(player_id :: String.t(), event :: String.t(), payload :: map()) :: :ok | no_return()
  defp push(player_id, event, payload) do
    MahWeb.UserSocket.id(player_id) |> MahWeb.Endpoint.broadcast!(event, payload)
  end
end
