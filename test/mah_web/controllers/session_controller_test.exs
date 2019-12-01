defmodule MahWeb.SessionControllerTest do
  use MahWeb.ConnCase, async: true

  describe "login as user" do
    setup do
      {:ok, user} = Mah.Identities.create_user(%{name: "john"})

      %{user: user}
    end

    test "renders token", %{conn: conn} do
      json =
        conn
        |> post(Routes.session_path(conn, :create), %{name: "john"})
        |> json_response(201)

      assert %{"token" => _} = json["data"]
    end
  end
end
