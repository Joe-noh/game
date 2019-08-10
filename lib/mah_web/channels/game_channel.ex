defmodule MahWeb.GameChannel do
  use MahWeb, :channel

  def join("game:" <> _game_id, _payload, socket) do
    send(self(), :track_presence)
    {:ok, socket}
  end

  def handle_info(:track_presence, socket) do
    push(socket, "presence_state", MahWeb.Presence.list(socket))
    {:ok, _} = MahWeb.Presence.track(socket, socket.assigns.user_id, %{})

    {:noreply, socket}
  end
end
