import Config

config :mah, MahWeb.Endpoint,
  url: [host: "example.com", port: 80],
  server: true

config :mah, :firebase, aud: "mah-production"

config :libcluster,
  topologies: [
    kubernetes: [
      strategy: Elixir.Cluster.Strategy.Kubernetes.DNS,
      config: [
        service: "mah-headless",
        application_name: "mah",
        polling_interval: 10_000
      ]
    ]
  ]

config :logger, level: :info
