defmodule MahWeb.Router do
  use MahWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :auth do
    plug Guardian.Plug.Pipeline,
      module: MahWeb.Guardian,
      error_handler: MahWeb.Guardian.ErrorHandler

    plug Guardian.Plug.VerifyHeader
    plug Guardian.Plug.EnsureAuthenticated
    plug Guardian.Plug.LoadResource
  end

  scope "/api", MahWeb do
    pipe_through [:auth, :api]

    resources "/users", UserController, only: [:show]
    resources "/participations", ParticipationController, only: [:create]
    resources "/games", GameController, only: [:show]
  end

  scope "/api", MahWeb do
    pipe_through [:api]

    resources "/users", UserController, only: [:create]
    resources "/sessions", SessionController, only: [:create]
  end
end
