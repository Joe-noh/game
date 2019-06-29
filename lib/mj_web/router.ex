defmodule MjWeb.Router do
  use MjWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", MjWeb do
    pipe_through :api
  end
end
