defmodule Mj.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    connect_nodes()

    children = [
      # Mj.Repo,
      {Horde.Supervisor, name: Mj.GameSupervisor, strategy: :one_for_one, members: horde_members(Mj.GameSupervisor)},
      {Horde.Registry, name: Mj.GameRegistry, keys: :unique, members: horde_members(Mj.GameRegistry)}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: Mj.Supervisor)
  end

  defp connect_nodes do
    case System.get_env("NODES") do
      nodes when is_binary(nodes) ->
        nodes
        |> String.split(",")
        |> Enum.map(&String.to_atom/1)
        |> Enum.each(&Node.connect/1)

      _ ->
        nil
    end
  end

  defp horde_members(name) do
    [Node.self() | Node.list()] |> Enum.map(fn node -> {name, node} end)
  end
end
