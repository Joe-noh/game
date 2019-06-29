defmodule Mj.Cluster.LocalStrategy do
  use Cluster.Strategy

  def start_link([%Cluster.Strategy.State{} = state]) do
    System.get_env("NODES") |> do_start_link(state)
    :ignore
  end

  defp do_start_link(nil, _state), do: nil

  defp do_start_link(nodes, %{topology: topology, connect: connect, list_nodes: list_nodes}) do
    atom_nodes = convert_to_nodes(nodes)
    Cluster.Strategy.connect_nodes(topology, connect, list_nodes, atom_nodes)
  end

  defp convert_to_nodes(nodes) do
    nodes
    |> String.split(",")
    |> Enum.map(&String.to_atom/1)
  end
end
