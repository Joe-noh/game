defmodule MjWeb.LobbyChannel do
  use MjWeb, :channel

  def join("lobby", _payload, socket) do
    {:ok, socket}
  end
end
