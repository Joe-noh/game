ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(Mj.Repo, :manual)

defmodule TestHelpers do
  def login(conn, user) do
    {:ok, token, _} = MjWeb.Guardian.encode_and_sign(user, %{})
    conn = Plug.Conn.put_req_header(conn, "authorization", "Bearer: #{token}")

    {:ok, conn}
  end
end
