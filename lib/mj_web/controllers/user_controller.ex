defmodule MjWeb.UserController do
  use MjWeb, :controller

  alias Mj.Identities

  action_fallback MjWeb.FallbackController

  def show(conn, %{"id" => id}) do
    user = Identities.get_user!(id)
    render(conn, "show.json", user: user)
  end

  def create(conn, %{"user" => user_params}) do
    with {:ok, user} <- Identities.create_user(user_params) do
      conn
      |> put_status(201)
      |> render("show.json", user: user)
    end
  end
end
