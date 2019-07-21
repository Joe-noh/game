defmodule MjWeb.GameChannel do
  use MjWeb, :channel

  def join("game:" <> _game_id, _payload, socket) do
    send(self(), :track_presence)
    {:ok, socket}
  end

  def handle_info(:track_presence, socket) do
    push(socket, "presence_state", MjWeb.Presence.list(socket))
    {:ok, _} = MjWeb.Presence.track(socket, socket.assigns.user_id, %{})

    {:noreply, socket}
  end
end
