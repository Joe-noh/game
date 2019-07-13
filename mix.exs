defmodule Mj.MixProject do
  use Mix.Project

  def project do
    [
      app: :mj,
      version: "0.1.0",
      elixir: "~> 1.5",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  def application do
    [
      mod: {Mj.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:ecto_sql, "~> 3.0"},
      {:elixir_uuid, "~> 1.2"},
      {:gettext, "~> 0.11"},
      {:guardian, "~> 1.2"},
      {:horde, "~> 0.6"},
      {:jason, "~> 1.0"},
      {:libcluster, "~> 3.1"},
      {:phoenix, "~> 1.4.7"},
      {:phoenix_ecto, "~> 4.0"},
      {:phoenix_pubsub, "~> 1.1"},
      {:plug_cowboy, "~> 2.0"},
      {:postgrex, ">= 0.0.0"}
    ]
  end

  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
