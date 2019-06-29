defmodule Mj.GameServer do
  use GenServer
  require Logger

  def child_spec(id) do
    %{id: id, start: {__MODULE__, :start_link, [id]}}
  end

  def start_link(id) do
    Logger.info("Starting GameServer (id: #{id})")
    GenServer.start_link(__MODULE__, id, name: via_tuple(id))
  end

  def hello(id) do
    GenServer.call(via_tuple(id), :hello)
  end

  def init(id) do
    {:ok, %{id: id}}
  end

  def handle_call(:hello, _from, state = %{id: id}) do
    {:reply, "hello from #{inspect(id)}, #{inspect(self())}", state}
  end

  defp via_tuple(id) do
    {:via, Registry, {Mj.GameRegistry, id}}
  end
end
