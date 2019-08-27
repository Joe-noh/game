import Config

config :mah, Mah.Repo,
  username: "postgres",
  password: "postgres",
  database: "mah_test",
  hostname: System.get_env("DB_HOST", "localhost"),
  port: String.to_integer(System.get_env("DB_PORT", "5432")),
  pool: Ecto.Adapters.SQL.Sandbox

config :mah, MahWeb.Endpoint,
  http: [port: 4002],
  server: false

config :libcluster,
  topologies: []

config :logger, level: :warn
