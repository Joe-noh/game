defmodule MjWeb.FallbackController do
  use MjWeb, :controller

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(MjWeb.ChangesetView)
    |> render("error.json", changeset: changeset)
  end

  def call(conn, {:error, :bad_request}) do
    render_error(conn, :bad_request, "400.json")
  end

  def call(conn, {:error, :unauthorized}) do
    render_error(conn, :unauthorized, "401.json")
  end

  def call(conn, {:error, :not_found}) do
    render_error(conn, :not_found, "404.json")
  end

  defp render_error(conn, reason, template) do
    conn
    |> put_status(reason)
    |> put_view(MjWeb.ErrorView)
    |> render(template)
  end
end
