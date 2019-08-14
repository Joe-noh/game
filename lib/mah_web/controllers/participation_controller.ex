defmodule MahWeb.ParticipationController do
  use MahWeb, :controller

  action_fallback MahWeb.FallbackController

  def create(conn, _params) do
    with %{id: player_id} = MahWeb.Guardian.Plug.current_resource(conn),
         {:ok, game_id} <- Mah.Matching.Server.start_or_join(player_id) do
      conn
      |> put_status(201)
      |> render("show.json", participation: %{game_id: game_id})
    else
      {:error, _reason} ->
        conn
        |> put_status(400)
        |> put_view(MahWeb.ErrorView)
        |> render("error.json")
    end
  end
end
