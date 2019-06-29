defmodule Mj.GameServer do
  use GenServer
  require Logger

  def child_spec(id) do
    %{id: id, start: {__MODULE__, :start_link, [id]}}
  end

  def start_link(id) do
    Logger.info("Starting GameServer (id: #{id})")
    GenServer.start_link(__MODULE__, [id], [])
  end

  def init(id) do
    {:ok, %{id: id}}
  end
end
