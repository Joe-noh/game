import Config

config :mah, Mah.Repo,
  username: "postgres",
  password: "postgres",
  database: "mah_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :mah, MahWeb.Endpoint,
  http: [port: 4002],
  server: false

config :libcluster,
  topologies: []

config :logger, level: :warn
