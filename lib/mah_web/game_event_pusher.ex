defmodule MahWeb.GameEventPusher do
  @moduledoc """
  This provides functions to push game events from server to clients.
  """

  @spec game_start(player_id :: String.t(), payload :: map()) :: :ok | no_return()
  def game_start(player_id, payload) do
    push(player_id, "game:start", payload)
  end

  @spec tsumo(player_id :: String.t(), payload :: map()) :: :ok | no_return()
  def tsumo(player_id, %{tsumohai: tsumohai, other_players: other_players}) do
    push(player_id, "game:tsumo", %{tsumohai: tsumohai})

    Enum.each(other_players, fn other ->
      push(other, "game:tacha_tsumo", %{player: player_id})
    end)
  end

  def dahai(%{player: player_id, players: players, hai: hai, tsumogiri: tsumogiri}) do
    Enum.each(players, fn player ->
      push(player, "game:dahai", %{player: player_id, hai: hai, tsumogiri: tsumogiri})
    end)
  end

  @spec push(player_id :: String.t(), event :: String.t(), payload :: map()) :: :ok | no_return()
  defp push(player_id, event, payload) do
    MahWeb.Endpoint.broadcast!("user:#{player_id}", event, payload)
  end
end
