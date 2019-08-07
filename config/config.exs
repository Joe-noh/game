import Config

config :mj,
  ecto_repos: [Mj.Repo],
  generators: [binary_id: true]

config :mj, MjWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "suaYOCRNaToqFR6sx+8N6suZU2s+6lOy64MbHuaWLaXsSQULS1Sm6JHFzTt4JwES",
  render_errors: [view: MjWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: Mj.PubSub, adapter: Phoenix.PubSub.PG2]

config :mj, MjWeb.Guardian,
  issuer: "mj",
  secret_key: "6x7/p/jsoEGWZ4Cu6TLaAB2MopJtKtP78vwwty7kXWMmVjgSe2kYupAy1cYskG3k"

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :json_library, Jason

import_config "#{Mix.env()}.exs"
