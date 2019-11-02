defmodule MahWeb.ParticipationController do
  use MahWeb, :controller

  action_fallback MahWeb.FallbackController

  def create(conn, _params) do
    %{id: player_id} = MahWeb.Guardian.Plug.current_resource(conn)
    {:ok, game_id} = Mah.Matching.spawn_or_join(player_id)

    conn
    |> put_status(201)
    |> render("show.json", participation: %{game_id: game_id})
  end
end
