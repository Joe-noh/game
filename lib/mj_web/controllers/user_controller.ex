defmodule MjWeb.UserController do
  use MjWeb, :controller

  alias Mj.Identities

  action_fallback MjWeb.FallbackController

  def show(conn, %{"id" => id}) do
    user = Identities.get_user!(id)
    render(conn, "show.json", user: user)
  end

  def create(conn, %{"user" => %{"id_token" => id_token}}) do
    with {:ok, payload} <- FirebaseJwt.verify(id_token),
         {:ok, %{user: user}} <- Identities.signup_with_firebase_payload(payload),
         {:ok, token, _claims} <- MjWeb.Guardian.encode_and_sign(user) do
      conn
      |> put_status(201)
      |> put_view(MjWeb.SessionView)
      |> render("show.json", %{token: token})
    end
  end

  def create(_conn, _) do
    {:error, :bad_request}
  end
end
