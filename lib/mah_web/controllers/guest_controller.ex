defmodule MahWeb.GuestController do
  use MahWeb, :controller

  action_fallback MahWeb.FallbackController

  def create(conn, _params) do
    with user = %{id: UUID.uuid4()},
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
end
