defmodule MjWeb.PageController do
  use MjWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
