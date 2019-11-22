defmodule MahWeb.SessionController do
  use MahWeb, :controller

  action_fallback MahWeb.FallbackController

  if Mix.env != :prod do
    def create(conn, %{"name" => name}) do
      with user <- Mah.Identities.get_user_by(name: name),
           {:ok, token, _claims} <- MahWeb.Guardian.encode_and_sign(user) do
        conn
        |> put_status(201)
        |> put_view(MahWeb.SessionView)
        |> render("show.json", %{token: token})
      end
    end
  else
    def create(_conn, _params) do
      {:error, :not_found}
    end
  end
end
