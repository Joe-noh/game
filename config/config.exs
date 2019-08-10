import Config

config :mah,
  ecto_repos: [Mah.Repo],
  generators: [binary_id: true]

config :mah, MahWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "suaYOCRNaToqFR6sx+8N6suZU2s+6lOy64MbHuaWLaXsSQULS1Sm6JHFzTt4JwES",
  render_errors: [view: MahWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: Mah.PubSub, adapter: Phoenix.PubSub.PG2]

config :mah, MahWeb.Guardian,
  issuer: "mah",
  secret_key: "6x7/p/jsoEGWZ4Cu6TLaAB2MopJtKtP78vwwty7kXWMmVjgSe2kYupAy1cYskG3k"

config :mah, :firebase, aud: "mah-development"

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :json_library, Jason

import_config "#{Mix.env()}.exs"
