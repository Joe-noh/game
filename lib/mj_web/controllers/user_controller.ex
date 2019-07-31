defmodule MjWeb.UserController do
  use MjWeb, :controller

  alias Mj.Identities

  action_fallback MjWeb.FallbackController

  def show(conn, %{"id" => id}) do
    user = Identities.get_user!(id)
    render(conn, "show.json", user: user)
  end

  def create(conn, %{"user" => user_params}) do
    with {:ok, user} <- Identities.create_user(user_params),
         {:ok, token, _claims} <- MjWeb.Guardian.encode_and_sign(user) do
      conn
      |> put_status(201)
      |> put_view(MjWeb.SessionView)
      |> render("show.json", %{token: token})
    end
  end
end
