defmodule Mj.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    topologies = Application.get_env(:libcluster, :topologies)

    children = [
      Mj.Repo,
      MjWeb.Endpoint,
      MjWeb.Presence,
      Mj.Matching.Server,
      {Horde.Supervisor, name: Mj.GameSupervisor, strategy: :one_for_one},
      {Horde.Registry, name: Mj.GameRegistry, keys: :unique},
      {Cluster.Supervisor, [topologies, [name: Mj.ClusterSupervisor]]},
      {Mj.Cluster.Connector, [[Mj.GameSupervisor, Mj.GameRegistry], [name: Mj.Cluster.Connector]]}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: Mj.Supervisor)
  end

  def config_change(changed, _new, removed) do
    MjWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
