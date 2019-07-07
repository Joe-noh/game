defmodule MjWeb.LobbyChannel do
  @moduledoc """
  Where people start or join a game.
  """

  use MjWeb, :channel

  def join("lobby", _payload, socket) do
    send(self(), :track_presence)
    {:ok, socket}
  end

  def handle_in("start_or_join", _, socket) do
    player_id = socket.assigns.user_id

    case Mj.Matching.Server.start_or_join(player_id) do
      {:ok, game_id} ->
        {:reply, {:ok, %{game_id: game_id}}, socket}
      :error ->
        {:reply, :error, socket}
    end
  end

  def handle_info(:track_presence, socket) do
    push(socket, "presence_state", MjWeb.Presence.list(socket))
    {:ok, _} = MjWeb.Presence.track(socket, socket.assigns.user_id, %{})

    {:noreply, socket}
  end
end
