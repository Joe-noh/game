defmodule MahWeb.UserSocket do
  use Phoenix.Socket

  channel "game:*", MahWeb.GameChannel

  def connect(%{"token" => token}, socket, _connect_info) do
    case MahWeb.Guardian.decode_and_verify(token) do
      {:ok, %{"sub" => user_id}} ->
        {:ok, assign(socket, :user_id, user_id)}

      _error ->
        :error
    end
  end

  def id(socket) do
    "user:#{socket.assigns.user_id}"
  end
end
