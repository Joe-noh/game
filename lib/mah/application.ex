defmodule Mah.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    topologies = Application.get_env(:libcluster, :topologies)

    children = [
      Mah.Repo,
      MahWeb.Endpoint,
      MahWeb.Presence,
      Mah.Matching.Server,
      {Horde.Supervisor, name: Mah.GameSupervisor, strategy: :one_for_one},
      {Horde.Registry, name: Mah.GameRegistry, keys: :unique},
      {Cluster.Supervisor, [topologies, [name: Mah.ClusterSupervisor]]},
      {Mah.Cluster.Connector, [[Mah.GameSupervisor, Mah.GameRegistry], [name: Mah.Cluster.Connector]]}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: Mah.Supervisor)
  end

  def config_change(changed, _new, removed) do
    MahWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
