defmodule MahWeb.GameChannel do
  use MahWeb, :channel

  def join("game:" <> game_id, _payload, socket) do
    send(self(), :track_presence)

    {:ok, assign(socket, :game_id, game_id)}
  end

  def handle_in("ready", _, socket = %{assigns: %{user_id: user_id, game_id: game_id}}) do
    if {:ok, :startable} == Mah.Game.player_ready(game_id, user_id) do
      players = MahWeb.Presence.list(socket) |> Map.keys()

      if Mah.Game.startable_with?(game_id, players) do
        Mah.Game.start_game(game_id)
      end
    end

    {:noreply, socket}
  end

  def handle_in("dahai", %{"hai" => hai}, socket = %{assigns: %{user_id: user_id, game_id: game_id}}) do
    case Mah.Game.dahai(game_id, user_id, hai) do
      :ok ->
        {:reply, {:ok, %{ok: true}}, socket}

      {:error, reason} ->
        {:reply, {:ok, %{ok: false, reason: reason}}, socket}
    end
  end

  def handle_info(:track_presence, socket) do
    push(socket, "presence_state", MahWeb.Presence.list(socket))
    {:ok, _} = MahWeb.Presence.track(socket, socket.assigns.user_id, %{})

    {:noreply, socket}
  end
end
