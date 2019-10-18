defmodule MahWeb.UserController do
  use MahWeb, :controller

  alias Mah.Identities

  action_fallback MahWeb.FallbackController

  def show(conn, %{"id" => id}) do
    user = Identities.get_user!(id)
    render(conn, "show.json", user: user)
  end

  def create(conn, %{"user" => %{"id_token" => id_token}}) do
    with {:ok, payload} <- IDToken.verify(id_token, module: IDToken.Firebase),
         {:ok, %{user: user}} <- Identities.signup_with_firebase_payload(payload),
         {:ok, token, _claims} <- MahWeb.Guardian.encode_and_sign(user) do
      conn
      |> put_status(201)
      |> put_view(MahWeb.SessionView)
      |> render("show.json", %{token: token})
    else
      :error -> {:error, :bad_request}
      other -> other
    end
  end

  def create(_conn, _) do
    {:error, :bad_request}
  end
end
