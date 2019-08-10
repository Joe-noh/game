ExUnit.start()
Faker.start()

Ecto.Adapters.SQL.Sandbox.mode(Mah.Repo, :manual)

defmodule TestHelpers do
  def login(conn, user) do
    {:ok, token, _} = MahWeb.Guardian.encode_and_sign(user, %{})
    Plug.Conn.put_req_header(conn, "authorization", "Bearer: #{token}")
  end

  def logout(conn) do
    Plug.Conn.delete_req_header(conn, "authorization")
  end
end
