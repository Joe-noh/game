defmodule MjWeb.LobbyChannel do
  use MjWeb, :channel

  def join("lobby", _payload, socket) do
    send(self(), :track_presence)
    {:ok, socket}
  end

  def handle_info(:track_presence, socket) do
    {:ok, _} = MjWeb.Presence.track(socket, socket.assigns.user_id, %{})
    {:noreply, socket}
  end
end
