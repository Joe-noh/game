defmodule MjWeb.UserController do
  use MjWeb, :controller

  alias Mj.Identities

  action_fallback MjWeb.FallbackController

  def create(conn, %{"user" => user_params}) do
    with {:ok, user} <- Identities.create_user(user_params) do
      conn
      |> put_status(201)
      |> render("show.json", user: user)
    end
  end
end
