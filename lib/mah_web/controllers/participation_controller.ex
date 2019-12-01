defmodule MahWeb.ParticipationController do
  use MahWeb, :controller

  action_fallback MahWeb.FallbackController

  alias Mah.{Identities, Matching}

  def create(conn, _params) do
    %{id: player_id} = MahWeb.Guardian.Plug.current_resource(conn)
    user = Identities.get_user!(player_id)

    case Matching.find_participation(player_id) do
      nil ->
        {:ok, %{table_id: table_id}} = Matching.create_table_or_participate(user)
        spawn_game(table_id, player_id)
        render_201(conn, table_id)

      %Matching.Participation{table_id: table_id} ->
        spawn_game(table_id, player_id)
        render_201(conn, table_id)
    end
  end

  defp spawn_game(table_id, player_id) do
    Matching.spawn_game(table_id)
    Mah.Game.add_player(table_id, player_id)
  end

  defp render_201(conn, game_id) do
    conn
    |> put_status(201)
    |> render("show.json", participation: %{game_id: game_id})
  end
end
