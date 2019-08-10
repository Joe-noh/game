import Config

config :mah, Mah.Repo,
  username: "postgres",
  password: "postgres",
  database: "mah_dev",
  hostname: "localhost",
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

config :mah, MahWeb.Endpoint,
  http: [port: 4000],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: []

config :libcluster,
  topologies: [
    local: [strategy: Mah.Cluster.LocalStrategy]
  ]

config :logger, :console, format: "[$level] $message\n"

config :phoenix, :stacktrace_depth, 20
config :phoenix, :plug_init_mode, :runtime
