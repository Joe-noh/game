import Config

config :mj, MjWeb.Endpoint,
  url: [host: "example.com", port: 80],
  server: true

config :libcluster,
  topologies: [
    kubernetes: [
      strategy: Elixir.Cluster.Strategy.Kubernetes.DNS,
      config: [
        service: "mj-headless",
        application_name: "mj",
        polling_interval: 10_000
      ]
    ]
  ]

config :logger, level: :info
