defmodule MjWeb.Router do
  use MjWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :auth do
    plug Guardian.Plug.Pipeline,
      module: MjWeb.Guardian,
      error_handler: MjWeb.Guardian.ErrorHandler

    plug Guardian.Plug.VerifyHeader
    plug Guardian.Plug.EnsureAuthenticated
    plug Guardian.Plug.LoadResource
  end

  scope "/api", MjWeb do
    pipe_through [:auth, :api]

    resources "/users", UserController, only: [:show]
    resources "/participations", ParticipationController, only: [:create]
  end

  scope "/api", MjWeb do
    pipe_through [:api]

    resources "/users", UserController, only: [:create]
    resources "/sessions", SessionController, only: [:create]
  end
end
