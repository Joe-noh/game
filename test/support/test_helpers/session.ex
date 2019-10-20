defmodule TestHelpers.Session do
  def login(conn, users) when is_list(users) do
    Enum.map(users, &login(conn, &1))
  end

  def login(conn, user) do
    {:ok, token, _} = MahWeb.Guardian.encode_and_sign(user, %{})
    Plug.Conn.put_req_header(conn, "authorization", "Bearer: #{token}")
  end

  def logout(conn) do
    Plug.Conn.delete_req_header(conn, "authorization")
  end
end
