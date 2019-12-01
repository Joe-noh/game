defmodule MahWeb.GameController do
  use MahWeb, :controller

  action_fallback MahWeb.FallbackController

  def show(conn, %{"id" => id}) do
    %{id: player_id} = MahWeb.Guardian.Plug.current_resource(conn)

    game = id |> Mah.Game.masked_for(player_id)
    render(conn, "show.json", game: game)
  end
end
