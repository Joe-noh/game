defmodule MjWeb.GameChannel do
  use MjWeb, :channel

  def join("game" <> _game_id, _payload, socket) do
    {:ok, socket}
  end
end
