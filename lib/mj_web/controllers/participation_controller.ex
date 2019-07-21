defmodule MjWeb.ParticipationController do
  use MjWeb, :controller

  action_fallback MjWeb.FallbackController

  def create(conn, _params) do
    with %{id: player_id} = MjWeb.Guardian.Plug.current_resource(conn),
         {:ok, game_id} <- Mj.Matching.Server.start_or_join(player_id) do
      conn
      |> put_status(201)
      |> render("show.json", participation: %{game_id: game_id})
    else
      {:error, _reason} ->
        conn
        |> put_status(400)
        |> render(MjWeb.ErrorView, "error.json")
    end
  end
end
