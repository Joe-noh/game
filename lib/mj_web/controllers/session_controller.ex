defmodule MjWeb.SessionController do
  use MjWeb, :controller

  alias Mj.Identities

  action_fallback MjWeb.FallbackController

  def create(conn, %{"session" => %{"name" => name, "password" => password}}) do
    case Identities.verify_password(name, password) do
      false ->
        {:error, :unauthorized}

      user ->
        {:ok, token, _claims} = MjWeb.Guardian.encode_and_sign(user)

        conn
        |> put_status(201)
        |> render("show.json", %{token: token})
    end
  end

  def create(_conn, _params) do
    {:error, :unauthorized}
  end
end
