defmodule MahWeb.GameChannel do
  use MahWeb, :channel

  def join("game:" <> game_id, _payload, socket) do
    send(self(), :track_presence)
    Process.send_after(self(), {:start_game, game_id}, 100)

    {:ok, assign(socket, :game_id, game_id)}
  end

  def handle_info(:track_presence, socket) do
    push(socket, "presence_state", MahWeb.Presence.list(socket))
    {:ok, _} = MahWeb.Presence.track(socket, socket.assigns.user_id, %{})

    {:noreply, socket}
  end

  def handle_info({:start_game, game_id}, socket) do
    players = MahWeb.Presence.list(socket) |> Map.keys()

    if Mah.Game.startable_with?(game_id, players) do
      Mah.Game.start_game(game_id)
    end

    {:noreply, socket}
  end
end
