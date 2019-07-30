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

config :argon2_elixir,
  t_cost: 1,
  m_cost: 8

config :libcluster,
  topologies: []

config :logger, level: :warn
