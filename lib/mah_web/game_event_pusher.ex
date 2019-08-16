defmodule MahWeb.GameEventPusher do
  @moduledoc """
  This provides functions to push game events from server to clients.
  """

  @spec game_start(payload :: map()) :: :ok | no_return()
  def game_start(%{players: players, hands: hands}) do
    Enum.each(players, fn player ->
      push(player, "game:start", %{players: players, hand: Map.get(hands, player)})
    end)
  end

  @spec tsumo(payload :: map()) :: :ok | no_return()
  def tsumo(%{player: player, players: players, tsumohai: tsumohai}) do
    Enum.each(players, fn
      ^player -> push(player, "game:tsumo", %{tsumohai: tsumohai})
      other -> push(other, "game:tacha_tsumo", %{player: player})
    end)
  end

  def dahai(%{player: player, players: players, hai: hai, tsumogiri: tsumogiri}) do
    Enum.each(players, fn id ->
      push(id, "game:dahai", %{player: player, hai: hai, tsumogiri: tsumogiri})
    end)
  end

  @spec push(player_id :: String.t(), event :: String.t(), payload :: map()) :: :ok | no_return()
  defp push(player_id, event, payload) do
    MahWeb.Endpoint.broadcast!("user:#{player_id}", event, payload)
  end
end
