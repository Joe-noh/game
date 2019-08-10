defmodule Mah.Cluster.Connector do
  use GenServer

  def start_link([names, opts]) do
    GenServer.start_link(__MODULE__, names, opts)
  end

  def init(names) do
    Process.send_after(self(), :trigger, 1_000)
    {:ok, names}
  end

  def handle_info(:trigger, names) do
    set_cluster_members(names)
    Process.send_after(self(), :trigger, 30_000)

    {:noreply, names}
  end

  defp set_cluster_members(names) do
    Enum.each(names, fn name ->
      me = {name, Node.self()}
      others = Node.list() |> Enum.map(&{name, &1})

      Horde.Cluster.set_members(me, [me | others])
    end)
  end
end
