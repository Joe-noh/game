defmodule MjWeb.GameEventPusher do
  @moduledoc """
  This provides functions to push game events from server to clients.
  """

  @spec game_start(player_id :: String.t(), payload :: Map.t()) :: no_return()
  def game_start(player_id, payload) do
    push(player_id, "game:start", payload)
  end

  @spec push(player_id :: String.t(), event :: String.t(), payload: Map.t()) :: no_return()
  defp push(player_id, event, payload) do
    MjWeb.Endpoint.broadcast!("user:#{player_id}", event, payload)
  end
end
