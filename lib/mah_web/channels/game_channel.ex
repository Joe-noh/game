defmodule MahWeb.GameChannel do
  use MahWeb, :channel

  alias MahWeb.GameChannel.EventPusher

  def join("game:" <> game_id, _payload, socket = %{assigns: %{user_id: user_id}}) do
    if Mah.Game.alive?(game_id) && Mah.Game.participated?(game_id, user_id) do
      send(self(), :track_presence)

      {:ok, assign(socket, :game_id, game_id)}
    else
      {:error, %{reason: "Game crashed"}}
    end
  end

  def handle_in("ready", _, socket = %{assigns: %{user_id: user_id, game_id: game_id}}) do
    Mah.Game.ready_player(game_id, user_id)

    if :ok == Mah.Game.start(game_id) do
      EventPusher.game_start(game_id)

      :ok = Mah.Game.tsumo(game_id)
      EventPusher.tsumo(game_id)
    end

    {:noreply, socket}
  end

  def handle_in("dahai", %{"hai" => hai}, socket = %{assigns: %{user_id: user_id, game_id: game_id}}) do
    case Mah.Game.dahai(game_id, user_id, hai) do
      {:ok, %{hai: hai, tsumogiri: tsumogiri}} ->
        {:ok, players} = Mah.Game.players(game_id)
        EventPusher.dahai(%{player: user_id, players: players, hai: hai, tsumogiri: tsumogiri})

        # TODO: Mah.Game.possible_actions(game_id)
        actions = []

        if actions == [] do
          {:ok, %{player: player, tsumohai: tsumohai}} = Mah.Game.next_tsumo(game_id)
          EventPusher.tsumo(%{player: player, players: players, tsumohai: tsumohai})

          {:noreply, socket}
        else
          # TODO: push actions, not implemented
          Enum.each(actions, fn _ -> nil end)

          {:noreply, socket}
        end

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
