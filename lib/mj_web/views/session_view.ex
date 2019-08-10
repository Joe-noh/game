defmodule MahWeb.SessionView do
  use MahWeb, :view

  def render("show.json", %{token: token}) do
    %{data: render_one(%{token: token}, __MODULE__, "session.json")}
  end

  def render("session.json", %{session: %{token: token}}) do
    %{
      token: token
    }
  end
end
