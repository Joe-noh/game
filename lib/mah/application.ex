defmodule Mah.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    topologies = Application.get_env(:libcluster, :topologies)

    children = [
      Mah.Repo,
      MahWeb.Endpoint,
      MahWeb.Presence,
      {Horde.Supervisor, name: Mah.GameStoreSupervisor, strategy: :one_for_one},
      {Horde.Registry, name: Mah.GameStoreRegistry, keys: :unique},
      {Cluster.Supervisor, [topologies, [name: Mah.ClusterSupervisor]]},
      {Mah.Cluster.Connector, [[Mah.GameStoreSupervisor, Mah.GameStoreRegistry], [name: Mah.Cluster.Connector]]}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: Mah.Supervisor)
  end

  def config_change(changed, _new, removed) do
    MahWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
