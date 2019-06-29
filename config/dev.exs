import Config

config :mj, Mj.Repo,
  username: "postgres",
  password: "postgres",
  database: "mj_dev",
  hostname: "localhost",
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

config :mj, MjWeb.Endpoint,
  http: [port: 4000],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: []

config :libcluster,
  topologies: [
    local: [strategy: Mj.Cluster.LocalStrategy]
  ]

config :logger, :console, format: "[$level] $message\n"

config :phoenix, :stacktrace_depth, 20
config :phoenix, :plug_init_mode, :runtime
