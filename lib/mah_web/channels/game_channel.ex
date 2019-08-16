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
        {:ok, %{player: player, tsumohai: tsumohai}} = Mah.Game.start_game(game_id)
        {:ok, players} = Mah.Game.players(game_id)
        {:ok, hands} = Mah.Game.hands(game_id)

        Enum.each(players, fn player ->
          MahWeb.GameEventPusher.game_start(player, %{players: players, hand: Map.get(hands, player)})
        end)

        MahWeb.GameEventPusher.tsumo(player, %{tsumohai: tsumohai, other_players: Enum.reject(players, & &1 == player)})
      end
    end

    {:noreply, socket}
  end

  def handle_in("dahai", %{"hai" => hai}, socket = %{assigns: %{user_id: user_id, game_id: game_id}}) do
    case Mah.Game.dahai(game_id, user_id, hai) do
      {:ok, %{hai: hai, tsumogiri: tsumogiri}} ->
        {:ok, players} = Mah.Game.players(game_id)
        MahWeb.GameEventPusher.dahai(%{player: user_id, players: players, hai: hai, tsumogiri: tsumogiri})

        actions = [] # Mah.Game.possible_actions(game_id)

        if actions == [] do
          {:ok, %{player: player, tsumohai: tsumohai}} = Mah.Game.next_tsumo(game_id)
          MahWeb.GameEventPusher.tsumo(player, %{tsumohai: tsumohai, other_players: Enum.reject(players, & &1 == player)})

          {:noreply, socket}
        else
          Enum.each(actions, fn _ -> nil end) # push actions, not implemented
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
