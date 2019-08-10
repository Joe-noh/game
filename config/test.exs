import Config

config :mj, Mj.Repo,
  username: "postgres",
  password: "postgres",
  database: "mj_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :mj, MjWeb.Endpoint,
  http: [port: 4002],
  server: false

config :libcluster,
  topologies: []

config :logger, level: :warn
